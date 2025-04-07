//
//  NetworkTask.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

/// Network task that can be scheduled, cancelled, and reported on.
///
/// All conforming types must be ``Sendable`` and must provide async access
/// to key task properties like the request, retry count, and configurations.
public protocol NetworkingTask: Sendable {
    /// A unique identifier for this task.
    var id: String {get}
    
    /// The underlying ``URLRequest`` associated with this task.
    var request: URLRequest {get async}
    
    /// The number of retry attempts made for this task.
    var retryCount: Int {get async}
    
    /// The current configuration values that influence task behavior.
    var configurations: ConfigurationValues {get async}
    
    /// The current ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    var sessionTask: URLSessionTask? {get async}
    
    /// Cancels the task if it's currently running.
    func cancel() async
    
    /// Resumes or starts the task execution.
    func resume() async
    
    /// Suspends the task if it's currently running.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    func suspend() async
    
    /// Sets the ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    func set(_ task: URLSessionTask) async
    
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDelegate`` during download.
    func session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async
}

extension NetworkingTask {
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDelegate`` during download.
    public func session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async { }
}


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
    
    /// The active configuration values for this task.
    public var configurations: ConfigurationValues {
        get async {
            return await state.configurations
        }
    }
    
    /// The current ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    public var sessionTask: URLSessionTask? {
        get async {
            return await state.sessionTask
        }
    }
    
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
        session: Session,
        configurations: ConfigurationValues
    ) {
        self.id = id
        self.session = session
        self.state = NetworkTaskState(configurations, request: request)
    }
    
// MARK: - Open Functions
    /// Executes the request and returns the expected result.
    ///
    /// This must be overridden in a subclass to implement task-specific logic.
    open func execute(
        _ request: borrowing URLRequest,
        session: Session
    ) async throws -> Response {
        fatalError("must override execute(for:session:)")
    }
    
    /// Called when the task has successfully started.
    ///
    /// Adds itself to the active tasks and logs the start if needed.
    open func started(
        with configurations: borrowing ConfigurationValues
    ) async {
        if configurations.logsEnabled {
            await NetworkLogger.logStarted(request: request, id: id)
        }
        await configurations.tasks.add(self, for: request)
    }
    
    /// Called when the task has finished execution (success or error).
    ///
    /// Removes itself from the task storage and logs the outcome.
    open func finished(
        with error: (any Error)?,
        configurations: borrowing ConfigurationValues
    ) async {
        await configurations.tasks.remove(request)
        if configurations.logsEnabled {
            await NetworkLogger.logFinished(request: request, id: id, error: error)
        }
    }
    
// MARK: - Public Functions
    /// Cancels the current task if any is running.
    public func cancel() async {
        await state.currentTask?.cancel()
    }
    
    /// Resumes the task by starting it or continuing it if already started.
    public func resume() async {
        guard await state.currentTask == nil else {
            await state.sessionTask?.resume()
            return
        }
        _ = await state.activeTask {
            try await self.start()
        }
    }
    
    /// Suspends the task if it's currently running.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    public func suspend() async {
        await state.sessionTask?.suspend()
    }
    
    /// Starts or resumes the task if needed and returns its response.
    @discardableResult public func response() async throws -> Response {
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
//        await state.configuration(keyPath, value)
        return self
    }
    
    /// Sets the ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    public func set(_ task: URLSessionTask) async {
        await state.set(task)
    }
    
// MARK: - Private Functions
    /// Starts the task with full interception and logging pipeline.
    private func start() async throws -> Response {
        let configurations = await configurations
        do {
            try await intercept(with: configurations.interceptor)
            if let interceptor = configurations.authHandler {
                try await intercept(with: interceptor)
            }
            await started(with: configurations)
            
            let result = try await perform(with: configurations)
            
            await finished(with: nil, configurations: configurations)
            return result
        }catch {
            await finished(with: error, configurations: configurations)
            throw error
        }
    }
    
    /// Performs the request, applying retry logic if needed.
    private func perform(
        with configurations: ConfigurationValues
    ) async throws -> Response {
        let retryPolicy = configurations.retryPolicy
        let maxRetryCount = retryPolicy.maxRetryCount
        
        for _ in 0..<maxRetryCount {
            do {
                let response = try await execute(
                    state.currentRequest,
                    session: session
                )
                if let status = response.1.status {
                    try await configurations.statusValidator._validate(
                        self,
                        status: status
                    )
                }
                
                return response
            }catch {
                try await handle(error: error)
            }
        }
        return try await execute(state.currentRequest, session: session)
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
    private func handle(error: some Error) async throws {
        try Task.checkCancellation()
        if let error = error as? NKError, case .unauthorized = error {
            try await configurations.authHandler?
                .refresh(with: session)
        }else {
            let retryPolicy = await configurations.retryPolicy
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
