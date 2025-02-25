//
//  RequestCommand.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

// TODO: - Add Upload Task
public actor RequestCommand {
// MARK: - Properties
    private let session: URLSession
    private nonisolated(unsafe) var configurations: NetworkConfigurations
    
// MARK: - Initializer
    public init(
        sessionDelegate: SessionDelegate = SessionDelegate(),
        configuration: URLSessionConfiguration = .default,
        delegateQueue queue: OperationQueue? = nil,
        tasksStorage: any TasksStorage = NetworkTasksStorage()
    ) {
        configurations = NetworkConfigurations(tasks: tasksStorage)
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: queue
        )
        sessionDelegate.tasks = configurations.tasks
    }
    public init(
        sessionDelegate: SessionDelegate = SessionDelegate(),
        configuration: () -> URLSessionConfiguration,
        delegateQueue queue: OperationQueue? = nil,
        tasksStorage: any TasksStorage = NetworkTasksStorage()
    ) {
        self.init(
            sessionDelegate: sessionDelegate,
            configuration: configuration(),
            delegateQueue: queue,
            tasksStorage: tasksStorage
        )
    }
    
// MARK: - Private Functions
    private nonisolated func set<Value>(
        _ value: Value,
        to keyPath: WritableKeyPath<NetworkConfigurations, Value>
    ) {
        configurations[keyPath: keyPath] = value
    }
    
// MARK: - Task Functions
    public nonisolated func dataTask(
        _ request: consuming some Request
    ) throws -> DataTask {
        let task = DataTask(
            id: request.id ?? UUID().uuidString,
            request: try request._urlRequest(configurations.url),
            session: session,
            configurations: configurations
        )
        return task
    }
    public nonisolated func downloadTask(
        _ request: consuming some Request
    ) throws -> DownloadTask {
        let task = DownloadTask(
            id: request.id ?? UUID().uuidString,
            request: try request._urlRequest(configurations.url),
            session: session,
            configurations: configurations
        )
        return task
    }
}

// MARK: - Modifiers
extension RequestCommand {
    nonisolated public func url(_ url: URL?) -> Self {
        set(url, to: \.url)
        return self
    }
    nonisolated public func url(_ url: String) -> Self {
        set(URL(string: url), to: \.url)
        return self
    }
    nonisolated public func encode(with encoder: JSONEncoder) -> Self {
        set(encoder, to: \.encoder)
        return self
    }
    nonisolated public func decode(with decoder: JSONDecoder) -> Self {
        set(decoder, to: \.decoder)
        return self
    }
    nonisolated public func enableLogs(_ enabled: Bool = true) -> Self {
        set(enabled, to: \.logsEnabled)
        return self
    }
    nonisolated public func enableBackgroundTasks(_ enabled: Bool = true) -> Self {
        set(enabled, to: \.backgroundTasksEnabled)
        return self
    }
}

// MARK: - Handlers
extension RequestCommand {
    nonisolated public func startHandler(_ startHandler: any TaskStartHandler) -> Self {
        set(startHandler, to: \.handlers.startHandler)
        return self
    }
    nonisolated public func onStart(
        _ handler: @escaping @Sendable (_ task: any NetworkingTask) async throws -> Void
    ) -> Self {
       set(DefaultTaskStartHandler(handler), to: \.handlers.startHandler)
        return self
    }
    
    nonisolated public func errorHandler(_ errorHandler: any ErrorHandler) -> Self {
        set(errorHandler, to: \.handlers.errorHandler)
        return self
    }
    nonisolated public func onFailure(
        _ handler: @escaping @Sendable (_ error: any Error, _ task: any NetworkingTask) async -> Void
    ) -> Self {
        set(DefaultErrorHandler(handler), to: \.handlers.errorHandler)
        return self
    }
    
    nonisolated public func retryPolicy(_ retryPolicy: any RetryPolicy) -> Self {
        set(retryPolicy, to: \.handlers.retryPolicy)
        return self
    }
    nonisolated public func doNotRetry() -> Self {
        let policy = DefaultRetryPolicy(maxRetryCount: 0)
        set(policy, to: \.handlers.retryPolicy)
        return self
    }
    nonisolated public func retry(
        limit: Int,
        for statuses: Set<ResponseStatus> = [],
        handler: (@Sendable (_ error: (any Error)?, _ status: ResponseStatus?, _ task: any NetworkingTask) async -> RetryResult)? = nil
    ) -> Self {
        let policy = DefaultRetryPolicy(
            maxRetryCount: limit,
            retryableStatuses: statuses,
            handler: handler
        )
        set(policy, to: \.handlers.retryPolicy)
        return self
    }
    
    nonisolated public func cacheHandler(_ cacheHandler: any ResponseCacheHandler) -> Self {
        set(cacheHandler, to: \.handlers.cacheHandler)
        return self
    }
    nonisolated public func redirectionHandler(_ redirectionHandler: any RedirectionHandler) -> Self {
        set(redirectionHandler, to: \.handlers.redirectionHandler)
        return self
    }
    
    nonisolated public func statusValidator(_ statusValidator: any StatusValidator) -> Self {
        set(statusValidator, to: \.handlers.statusValidator)
        return self
    }
    nonisolated public func validate(
        for statuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: (@Sendable (_ status: ResponseStatus, _ task: any NetworkingTask) async -> (any Error)?)? = nil
    ) -> Self {
        let statusValidator = DefaultStatusValidator(
            validStatuses: statuses,
            handler
        )
        set(statusValidator, to: \.handlers.statusValidator)
        return self
    }
}
