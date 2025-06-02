//
//  NetworkTaskState.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation
import NetworkingCore

/// The state of a network task, including its request,
/// configuration values, retry logic, and task lifecycle.
///
/// This actor ensures thread-safe mutation and access to task-related state.
/// It is generic over the response type `T`, which must conform to ``Sendable``.
internal actor NetworkTaskState<T: Sendable> {
// MARK: - Properties
    /// The number of retry attempts made for this task.
    internal var retryCount = 0
    
    internal var metrics: URLSessionTaskMetrics?
    
    /// The currently running ``Task``, if any.
    internal var currentTask: Task<T, any Error>?
    
    /// The current URL request, potentially updated by interceptors.
    internal var urlRequest: URLRequest?
    
    /// The current URL request, potentially updated by interceptors.
    internal var request: AnyRequest
    
    /// The current ``URLSessionTask``.
    internal var sessionTask: URLSessionTask?
    
// MARK: - Initializer
    /// Creates a new ``NetworkTaskState``.
    ///
    /// - Parameter request: The initial ``URLRequest`` for the task.
    internal init(request: AnyRequest) {
        self.request = request
    }
    
// MARK: - Functions
    /// Resets the current task and increments the retry count.
    ///
    /// Cancels any running task and prepares the state for a retry.
    internal func resetTask() {
        retryCount += 1
        currentTask?.cancel()
        currentTask = nil
    }
    
    /// Returns an active task if available; otherwise, creates a new one using the provided operation.
    ///
    /// - Parameter perform: A closure that performs the async operation.
    /// - Returns: The active or newly created ``Task``.
    internal func activeTask(
        _ perform: sending @isolated(any) @escaping () async throws -> T
    ) -> Task<T, any Error> {
        guard currentTask == nil else {
            return currentTask!
        }
        currentTask = Task {
            try await perform()
        }
        return currentTask!
    }
    
    /// Replaces the current request with a new one.
    ///
    /// - Parameter request: The new ``URLRequest`` to use.
    internal func set(_ urlRequest: consuming URLRequest) {
        self.urlRequest = urlRequest
    }
    
    internal func set(_ metrics: URLSessionTaskMetrics?) {
        self.metrics = metrics
    }
    
    /// Sets the ``URLSessionTask``.
    internal func set(_ task: URLSessionTask) {
        sessionTask = task
    }
}
