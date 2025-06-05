//
//  NetworkTaskState.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation
import NetworkingCore

/// The internal state of a network task, including its request,
/// retry tracking, session task references, and lifecycle management.
///
/// `NetworkTaskState` ensures isolated, thread-safe access to all mutable
/// components of a task’s execution. It manages the retry count, request resolution,
/// metrics tracking, and cancellation-safe task re-use.
///
/// This actor is generic over the expected response type `T`, which must conform to ``Sendable``.
internal actor NetworkTaskState<T: Sendable> {
// MARK: - Properties
    /// The number of times the task has been retried.
    internal var retryCount = 0
    
    /// The session task metrics recorded during the request, if available.
    internal var metrics: URLSessionTaskMetrics?
    
    /// The currently running `Task`, if any.
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
    
    /// The current `URLSessionTask` instance, if any.
    internal var sessionTask: URLSessionTask?
    
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
}
