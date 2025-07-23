//
//  NetworkTaskValues.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation
import NetworkingCore

/// The internal state of a network task, including its request,
/// retry tracking, session task references, and lifecycle management.
///
/// `NetworkTaskValues` ensures isolated, thread-safe access to all mutable
/// components of a task’s execution. It manages the retry count, request resolution,
/// metrics tracking, and cancellation-safe task re-use.
///
/// This actor is generic over the expected response type `T`, which must conform to ``Sendable``.
internal actor NetworkTaskValues<T: Sendable> {
// MARK: - Properties
    /// The number of times the task has been retried.
    internal var retryCount = 0
    
    /// The session task metrics recorded during the request, if available.
    internal var metrics: URLSessionTaskMetrics?
    
    /// The currently running ``Task``, if any.
    ///
    /// This is used to coalesce duplicate execution attempts and manage
    /// cancellation state during request resolution.
    internal var currentTask: Task<T, any Error>?
    
    /// The ``URLRequest`` used to perform the request.
    ///
    /// This value is updated after interception and reused on retry.
    internal var urlRequest: URLRequest?
    
    /// The underlying type-erased request.
    internal var request: AnyRequest
    
    /// The current ``URLSessionTask`` instance, if any.
    internal var sessionTask: URLSessionTask?
    
    /// The stream continuation for emitting progress values.
    private var stateStreamContinuation: AsyncStream<TaskState>.Continuation? {
        didSet {
            stateStreamContinuation?.yield(state)
        }
    }
    
    /// A stream that emits state updates throughout the task lifecycle.
    internal private(set) lazy var stateStream: AsyncStream<TaskState> = {
        return AsyncStream(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            self.stateStreamContinuation = continuation
        }
    }()
    
    /// The current execution state of a task.
    internal private(set) var state = TaskState.created {
        didSet {
            stateStreamContinuation?.yield(state)
        }
    }
    
// MARK: - Initializer
    /// Creates a new task state container.
    ///
    /// - Parameter request: The type-erased request associated with the task.
    internal init(request: AnyRequest) {
        self.request = request
    }
    
// MARK: - Functions
    /// Cancels any existing session task and prepares state for retry.
    ///
    /// This method clears metrics and resets the task-specific state.
    /// It also increments the retry count.
    internal func resetTask() {
        retryCount += 1
        sessionTask = nil
        metrics = nil
    }
    
    /// Returns an active task if one exists; otherwise creates a new one.
    ///
    /// Use this to ensure only a single instance of the operation runs,
    /// avoiding duplicate execution in concurrent contexts.
    ///
    /// - Parameter perform: A closure that performs the asynchronous work.
    /// - Returns: A `Task` representing the running or new operation.
    internal func activeTask(
        _ perform: sending @isolated(any) @escaping () async throws -> T
    ) -> Task<T, any Error> {
        if let currentTask {
            return currentTask
        }
        currentTask = Task {
            try await perform()
        }
        return currentTask!
    }
    
    /// Sets the latest ``URLRequest`` used to perform the request.
    ///
    /// - Parameter urlRequest: The fully resolved and intercepted request.
    internal func set(_ urlRequest: consuming URLRequest) {
        self.urlRequest = urlRequest
    }
    
    /// Stores the task metrics from the completed request.
    internal func set(_ metrics: URLSessionTaskMetrics?) {
        self.metrics = metrics
    }
    
    /// Stores the reference to the ``URLSessionTask`` instance executing the request.
    internal func set(_ task: URLSessionTask) {
        sessionTask = task
    }
    
    /// Attempts to transition the task to a new state.
    ///
    /// This method validates whether the current state can transition
    /// to the specified `newState`, and updates the internal state if the transition is allowed.
    ///
    /// - Parameter newState: The target state to transition to.
    /// - Returns: Wether the state has transitioned.
    @discardableResult
    internal func transition(to newState: TaskState) -> Bool {
        guard state.canTransition(to: newState) else {
            return false
        }
        state = newState
        return true
    }
    
    /// Completes the state stream and clears the continuation.
    ///
    /// Call this when the task has finished or been cancelled.
    internal func finish() {
        stateStreamContinuation?.finish()
        stateStreamContinuation = nil
    }
}

/// A network task's execution state.
public enum TaskState: Int, Sendable, Equatable, Hashable {
    /// The task has been created but has not yet started.
    case created
    
    /// The task is currently running.
    case running
    
    /// The task is currently being intercepted.
    case intercepting
    
    /// The task is suspended and may be resumed.
    case suspended
    
    /// The task has been cancelled and will not continue.
    case cancelled
    
    /// The task has finished, either successfully or with an error.
    case completed
    
    /// Whether this state can transition to another.
    ///
    /// Use this method to validate state transitions when updating a task's lifecycle.
    ///
    /// - Parameter other: The state to transition to.
    /// - Returns: `true` if the transition is allowed; otherwise, `false`.
    internal func canTransition(to other: Self) -> Bool {
        switch (self, other) {
            case (.created, .running), (.created, .cancelled):
                return true
            case (.running, .suspended), (.running, .cancelled), (.running, .completed), (.running, .intercepting):
                return true
            case (.intercepting, .running), (.intercepting, .cancelled), (.intercepting, .completed):
                return true
            case (.suspended, .running), (.suspended, .cancelled):
                return true
            default:
                return false
        }
    }
}
