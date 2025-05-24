//
//  NetworkTask.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation
import NetworkingCore

// TODO: - I'm not too happy with the current implementation of tasks and client. Can they be improved?
// TODO: - Should we pass Request instead of URLRequest? This will help remove interceptors.

/// Task representing the full lifecycle of a request, including retry logic,
/// configuration management, and logging.
///
/// - Note: The task manages its own retry policy and handles interceptor chains.
///
/// - Note: Subclasses must override the ``execute(_:session:)`` method to implement
/// the actual network call logic.
open class NetworkTask<T: Sendable>: NetworkingTask, Configurable, @unchecked Sendable {
    public typealias Response = (T, URLResponse)
// MARK: - Properties
    /// A unique identifier for the task.
    public let id: String
    
    /// The current URL request, potentially updated by interceptors.
    public var request: URLRequest {
        get async {
            return await state.currentRequest
        }
    }
    
    /// The number of retry attempts made for this task.
    public var retryCount: Int {
        get async {
            return await state.retryCount
        }
    }
    
    /// The current task metrics.
    public var metrics: URLSessionTaskMetrics? {
        get async {
            return await state.metrics
        }
    }
    // TODO: - Add a way to notify the user of the received metrics.
    
    /// The active configuration values for this task.
    @Configurations @preconcurrency public var configurations
    
    /// The session to use for networking.
    private let session: Session
    
    /// The thread safe state of the task.
    private let state: NetworkTaskState<Response>
    
// MARK: - Initializer
    /// Creates a new ``NetworkTask``.
    ///
    /// - Parameters:
    ///   - id: A unique task identifier.
    ///   - request: The original request to be executed.
    ///   - session: The session to use for networking.
    ///   - configurations: Configuration values to control the task.
    public init(
        id: String,
        request: consuming URLRequest,
        session: Session
    ) {
        self.id = id
        self.session = session
        self.state = NetworkTaskState(request: request)
    }
    
// MARK: - Open Functions
    /// Executes the request and returns the expected result.
    ///
    /// This must be overridden in a subclass to implement task-specific logic.
    open func _execute(
        _ request: borrowing URLRequest,
        session: Session
    ) async throws -> Response {
        fatalError("must override execute(_:session:)")
    }
    
    /// Called when the task has successfully started.
    ///
    /// Adds itself to the active tasks and logs the start if needed.
    open func _started() async {
        if configurations.logsEnabled {
            await NetworkLogger.logStarted(request: request, id: id)
        }
        await configurations.tasks.add(self, for: request)
    }
    
    /// Called when the task has finished execution (success or error).
    ///
    /// Removes itself from the task storage and logs the outcome.
    open func _finished(with error: (any Error)?) async {
        await configurations.tasks.remove(request)
        if configurations.logsEnabled {
            await NetworkLogger.logFinished(request: request, id: id, error: error)
        }
    }
    
// MARK: - Public Functions
    /// Cancels the current task if any is running.
    @discardableResult public func cancel() async -> Self {
        await state.currentTask?.cancel()
        return self
    }
    
    /// Resumes the task by starting it or continuing it if already started.
    @discardableResult public func resume() async -> Self {
        if await state.currentTask == nil {
            _ = await state.activeTask {
                try await self.start()
            }
        }else {
            await state.sessionTask?.resume()
        }
        return self
    }
    
    /// Starts or resumes the task if needed and returns its response.
    @discardableResult public func response() async throws -> sending Response {
        return try await state.activeTask {
            try await self.start()
        }.value
    }
    
    /// Sets a configuration value using a key path.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the configuration property.
    ///   - value: The new value to set.
    public func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self {
//        configurations[keyPath: keyPath] = value
        return self
    }
    
    public func _session(collected metrics: URLSessionTaskMetrics) async {
        await state.set(metrics)
    }
    
// MARK: - Private Functions
    /// Starts the task with full interception and logging pipeline.
    private func start() async throws -> Response {
        do {
            await _started()
            
            let result = try await perform()
            
            await _finished(with: nil)
            return result
        }catch {
            await _finished(with: error)
            throw error
        }
    }
    
    /// Performs the request, applying retry logic if needed.
    private func perform() async throws -> Response {
        let retryPolicy = configurations.retryPolicy
        let maxRetryCount = retryPolicy.maxRetryCount
        
        for _ in 0...maxRetryCount {
            do {
                try await intercept(with: configurations.interceptor)
                if let interceptor = configurations.authHandler {
                    try await intercept(with: interceptor)
                }
                let response = try await _execute(state.currentRequest, session: session)
                
                if let status = response.1.status {
                    try await configurations.statusValidator._validate(
                        self,
                        status: status
                    )
                }
                
                return response
            }catch {
                try await handle(error: error, retryPolicy: retryPolicy)
            }
        }
        throw NetworkingError.unexpectedError
    }
    
    /// Applies a request interceptor and updates the internal request.
    @inline(__always) private func intercept(
        with interceptor: any RequestInterceptor
    ) async throws {
        let intercepted = try await interceptor.intercept(
            state.currentRequest,
            for: self,
            with: session
        )
        await state.update(request: intercepted)
    }
    
    /// Handles the error thrown by the task and determines whether the request should be retried.
    private func handle(error: some Error, retryPolicy: any RetryPolicy) async throws {
        try Task.checkCancellation()
        if let error = error as? NetworkingError.ClientError, case .unauthorized = error {
            try await configurations.authHandler?
                .refresh(with: session)
        }else {
            let retryResult = await retryPolicy._shouldRetry(self, error: error, status: nil)
            guard retryResult.shouldRetry else {
                throw error
            }
            if let delay = retryResult.delay {
                try? await Task.sleep(nanoseconds: UInt64(delay))
            }
        }
        await state.resetTask()
    }
}

extension NetworkTask: _DynamicConfigurable {
    /// Applies the given configuration values to this task.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        _configurations._accept(values)
    }
}

extension NetworkTask {
    /// The current ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    internal var _sessionTask: URLSessionTask? {
        get async {
            return await state.sessionTask
        }
    }
    
    /// Suspends the task if it's currently running.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    @discardableResult public func suspend() async -> Self {
        await state.sessionTask?.suspend()
        return self
    }
    
    /// Sets the ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    public func _set(_ task: URLSessionTask) async {
        await state.set(task)
    }
}
