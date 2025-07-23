//
//  NetworkTask.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation
import NetworkingCore

public typealias Interceptor = RequestInterceptor & ResponseInterceptor

/// Task representing the full lifecycle of a request, including retry logic,
/// configuration management, and logging.
///
/// - Note: The task manages its own retry policy and handles interceptor chains.
///
/// - Note: Subclasses must override the ``execute(_:session:)`` method to implement
/// the actual network call logic.
open class NetworkTask<T: Sendable>: @unchecked Sendable {
    public typealias Response = (T, URLResponse)
// MARK: - Properties
    /// A unique identifier for the task.
    public let id: String
    
    /// The active configuration values for this task.
    @Configurations public var configurations
    
    /// The session to use for networking.
    private let session: Session
    
    /// The thread safe state of the task.
    private let values: NetworkTaskValues<Response>
    
    /// The underlying ``URLSessionTask``.
    internal var sessionTask: URLSessionTask? {
        get async {
            return await values.sessionTask
        }
    }
    
    /// The type-erased request associated with the task.
    ///
    /// This value represents the original ``Request`` used to construct
    /// and execute the task. It is resolved from internal state.
    ///
    /// You can use this to inspect the request metadata or re-execute it.
    public var request: AnyRequest {
        get async {
            return await values.request
        }
    }
    
    /// The resolved ``URLRequest`` used to perform the task, if available.
    ///
    /// This value is set after the request has been constructed and
    /// intercepted, and may be `nil` if the task hasn't started yet.
    ///
    /// You can inspect this to view the final request sent over the network.
    public var urlRequest: URLRequest? {
        get async {
            return await values.urlRequest
        }
    }
    
// MARK: - Initializer
    /// Creates a new ``NetworkTask``.
    ///
    /// - Parameters:
    ///   - request: The original request to be executed.
    ///   - session: The session to use for networking.
    public init(
        request: AnyRequest,
        session: Session
    ) {
        self.id = request.id
        self.session = session
        self.values = NetworkTaskValues(request: request)
    }
    
// MARK: - Functions
    /// Executes the request and returns the expected result.
    ///
    /// This must be overridden in a subclass to implement task-specific logic.
    ///
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    open func _execute(
        _ urlRequest: borrowing URLRequest,
        session: Session
    ) async throws(NetworkingError) -> Response {
        fatalError("must override execute(_:session:)")
    }
    
    /// Called when the task has finished execution (success or error).
    ///
    /// Removes itself from the task storage and logs the outcome.
    ///
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    open func _finished(with error: NetworkingError?) async {
        await values.transition(to: .completed)
        await values.finish()
        if let urlRequest = await values.urlRequest {
            await configurations.tasks.remove(urlRequest)
        }
    }

    /// Starts or resumes the task if needed and returns its response.
    ///
    /// - Throws: A ``NetworkingError`` if request construction fails.
    @discardableResult public func response() async throws(NetworkingError) -> sending Response {
        guard await state != .cancelled else {
            throw .cancellation
        }
        await values.transition(to: .running)
        return try await currentTask().typedValue
    }
}

// MARK: - Private Functions
extension NetworkTask {
    /// Begins or retrieves the active task for the current request.
    ///
    /// - Returns: A task representing the lifecycle of the current request.
    private func currentTask() async -> Task<Response, any Error> {
        return await values.activeTask {
            let result = await self.perform()
            await self._finished(with: result.error)
            return try result.get()
        }
    }
    
    /// Performs the full request lifecycle, including execution and response interception.
    ///
    /// This method:
    /// - Constructs the ``URLRequest``
    /// - Executes the request via `_execute`
    /// - Wraps the result in a ``Result``
    /// - Creates an ``InterceptorContext``
    /// - Passes the result through the configured response interceptor
    ///
    /// If the interceptor returns `.retry`, this method recursively restarts itself.
    /// Errors are caught and returned as `.failure(...)` results.
    ///
    /// - Returns: A result containing the response or an error.
    func perform() async -> Result<Response, NetworkingError> {
        var result: Result<Response, NetworkingError>
        do throws(NetworkingError) {
            let urlRequest = try await makeURLRequest()
            let response = try await _execute(urlRequest, session: session)
            result = .success(response)
        }catch {
            result = .failure(error)
        }
        
        await values.transition(to: .intercepting)
        
        do throws(NetworkingError) {
            try Task.checkTypedCancellation()
            let context = await InterceptorContext(
                configurations: configurations,
                status: result.value?.1.status,
                retryCount: retryCount,
                urlRequest: values.urlRequest,
                error: result.error
            )
            let intercepted = try await configurations.taskInterceptor.intercept(
                self,
                for: session,
                with: context
            )
            switch intercepted {
                case .continue:
                    return result
                case .failure(let error):
                    return .failure(error.networkingError)
                case .retry:
                    await values.resetTask()
                    return await perform()
            }
        }catch {
            return .failure(error)
        }
    }
    
    /// Creates and intercepts a ``URLRequest`` for the current task.
    ///
    /// This method:
    /// - Removes any previously stored request from tracking
    /// - Builds a new request using the base ``Request`` value
    /// - Passes the request through the configured ``RequestInterceptor``
    /// - Stores the result in `state` and registers it for tracking
    ///
    /// - Returns: A fully constructed and intercepted ``URLRequest``.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    private func makeURLRequest() async throws(NetworkingError) -> URLRequest {
        if let oldRequest = await values.urlRequest {
            await configurations.tasks.remove(oldRequest)
        }
        var urlRequest = try await request._makeURLRequest(with: configurations)
        urlRequest = try await configurations.taskInterceptor.intercept(
            self,
            request: consume urlRequest,
            for: session,
            with: configurations
        )
        await configurations.tasks.add(self, for: urlRequest)
        await values.set(urlRequest)
        return urlRequest
    }
}

// MARK: - _DynamicConfigurable
extension NetworkTask: _DynamicConfigurable {
    /// Applies the given configuration values to this task.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        _configurations._accept(values)
    }
}

// MARK: - Configurable
extension NetworkTask: Configurable {
    /// Sets a configuration value using a key path.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the configuration property.
    ///   - value: The new value to set.
    @discardableResult public func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self {
        _configurations.setValue(value, for: keyPath)
        return self
    }
}

// MARK: - NetworkingTask
extension NetworkTask: NetworkingTask {
    /// The number of retry attempts made for this task.
    public var retryCount: Int {
        get async {
            return await values.retryCount
        }
    }
    
    /// The current task metrics.
    public var metrics: URLSessionTaskMetrics? {
        get async {
            return await values.metrics
        }
    }
    
    /// The current execution state of a task.
    public var state: TaskState {
        get async {
            return await values.state
        }
    }
    
    /// A stream that emits state updates throughout the task lifecycle.
    public var stateUpdates: AsyncStream<TaskState> {
        return values.stateStream.stream
    }
    
    /// Called when a task has finished collecting metrics.
    ///
    /// This is typically called by the ``URLSessionTaskDelegate``.
    ///
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _session(collected metrics: URLSessionTaskMetrics) async {
        await values.set(metrics)
    }
    
    /// Sets the ``URLSessionTask``.
    ///
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    public func _set(_ task: URLSessionTask) async {
        await values.set(task)
    }
    
    /// Cancels the current task if any is running.
    @discardableResult public func cancel() async -> Self {
        guard await values.transition(to: .cancelled) else {
            return self
        }
        await values.currentTask?.cancel()
        return self
    }
    
    /// Resumes the task by starting it or continuing it if already started.
    @discardableResult public func resume() async -> Self {
        guard await values.transition(to: .running) else {
            return self
        }
        if await values.currentTask == nil {
            _ = await currentTask()
        }else {
            await values.sessionTask?.resume()
        }
        return self
    }
    
    /// Suspends the task if it's currently running.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    @discardableResult public func suspend() async -> Self {
        guard await values.transition(to: .suspended) else {
            return self
        }
        await values.sessionTask?.suspend()
        return self
    }
}
