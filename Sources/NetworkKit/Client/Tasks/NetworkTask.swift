//
//  NetworkTask.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

public protocol NetworkingTask: Sendable {
    var id: String {get}
    var request: URLRequest {get}
    var retryCount: Int {get async}
    var configurations: NetworkConfigurations {get async}
    
    func run() async
    func cancel() async
}

open class NetworkTask<T: Sendable>: NSObject, NetworkingTask, @unchecked Sendable {
// MARK: - Properties
    public let id: String
    public let request: URLRequest
    public var retryCount: Int {
        get async {
            return await state.retryCount
        }
    }
    public var configurations: NetworkConfigurations {
        get async {
            return await state.configurations
        }
    }
    
    private let session: URLSession
    internal let state: NetworkTaskState<T>
    
// MARK: - Initializer
    public init(
        id: String,
        request: consuming URLRequest,
        session: URLSession,
        configurations: NetworkConfigurations
    ) {
        self.id = id
        self.request = request
        self.session = session
        self.state = NetworkTaskState(configurations: configurations)
    }
    
// MARK: - Open Functions
    open func task(
        for request: borrowing URLRequest,
        session: URLSession
    ) async throws -> T {
        fatalError("must override task(for:session:)")
    }
    open func finished(
        with error: (any Error)?,
        configurations: NetworkConfigurations
    ) async {
        await configurations.tasks.remove(request)
        NetworkLogger.logFinished(task: self, error: nil, logsEnabled: configurations.logsEnabled)
    }
  
// MARK: - Public Functions
    public func activeTask() async -> Task<T, any Error> {
        return await state.activeTask {
            try await self.start()
        }
    }
    @inlinable public func run() async {
        _ = await activeTask()
    }
    public func cancel() async {
        await state.currentTask?.cancel()
    }
  
// MARK: - Private Functions
    private func start() async throws -> T {
        let configurations = await configurations
        let tasks = configurations.tasks
        do {
            try await configurations.handlers.startHandler.willStart(self)
            NetworkLogger.logStarted(task: self, logsEnabled: configurations.logsEnabled)
            await tasks.add(self)
            
            let result = try await perform(with: configurations)
            
            await finished(with: nil, configurations: configurations)
            return result
        }catch {
            await finished(with: nil, configurations: configurations)
            await configurations.handlers.errorHandler.handle(error, for: self)
            throw error
        }
    }
    private func perform(with configurations: NetworkConfigurations) async throws -> T {
        let retryPolicy = configurations.handlers.retryPolicy
        let maxRetryCount = retryPolicy.maxRetryCount
        
        for _ in 0..<maxRetryCount {
            do {
                return try await performTask()
            }catch {
                try Task.checkCancellation()
                try await handleRetry(error: error, retryPolicy: retryPolicy)
            }
        }
        return try await performTask()
    }
    @inline(__always) private func performTask() async throws -> T {
        try Task.checkCancellation()
        return try await task(for: request, session: session)
    }
    private func handleRetry(error: any Error, retryPolicy: any RetryPolicy) async throws {
        let retryResult = await retryPolicy._shouldRetry(
            self,
            error: error,
            status: nil
        )
        guard retryResult.shouldRetry else {
            throw error
        }
        if let delay = retryResult.delay {
            try? await Task.sleep(nanoseconds: UInt64(delay))
        }
        await state.incrementRetryCount()
    }
}

// MARK: - Modifiers
extension NetworkTask {
    public func encode(with encoder: JSONEncoder) async -> Self {
        await state.set(encoder, to: \.encoder)
        return self
    }
    public func decode(with decoder: JSONDecoder) async -> Self {
        await state.set(decoder, to: \.decoder)
        return self
    }
    public func enableLogs(_ enabled: Bool = true) async -> Self {
        await state.set(enabled, to: \.logsEnabled)
        return self
    }
    public func canRunInTheBackground(
        enabled: Bool = true,
        _ taskName: String? = nil
    ) async -> Self {
        await state.set(enabled, to: \.backgroundTasksEnabled)
        await state.setTaskName(taskName)
        return self
    }
}

// MARK: - Handlers
extension NetworkTask {
    public func startHandler(_ startHandler: any TaskStartHandler) async -> Self {
        await state.set(startHandler, to: \.handlers.startHandler)
        return self
    }
    public func onStart(
        _ handler: @escaping @Sendable (_ task: any NetworkingTask) async throws -> Void
    ) async -> Self {
        await state.set(DefaultTaskStartHandler(handler), to: \.handlers.startHandler)
        return self
    }
    
    public func errorHandler(_ errorHandler: any ErrorHandler) async -> Self {
        await state.set(errorHandler, to: \.handlers.errorHandler)
        return self
    }
    public func onFailure(
        _ handler: @escaping @Sendable (_ error: any Error, _ task: any NetworkingTask) async -> Void
    ) async -> Self {
        await state.set(DefaultErrorHandler(handler), to: \.handlers.errorHandler)
        return self
    }
    
    public func retryPolicy(_ retryPolicy: any RetryPolicy) async -> Self {
        await state.set(retryPolicy, to: \.handlers.retryPolicy)
        return self
    }
    public func doNotRetry() async -> Self {
        let policy = DefaultRetryPolicy(
            maxRetryCount: 0
        )
        await state.set(policy, to: \.handlers.retryPolicy)
        return self
    }
    public func retry(
        limit: Int,
        for statuses: Set<ResponseStatus> = [],
        handler: (@Sendable (_ error: (any Error)?, _ status: ResponseStatus?, _ task: any NetworkingTask) async -> RetryResult)? = nil
    ) async -> Self {
        let policy = DefaultRetryPolicy(
            maxRetryCount: limit,
            retryableStatuses: statuses,
            handler: handler
        )
        await state.set(policy, to: \.handlers.retryPolicy)
        return self
    }
    
    public func cacheHandler(_ cacheHandler: any ResponseCacheHandler) async -> Self {
        await state.set(cacheHandler, to: \.handlers.cacheHandler)
        return self
    }
    public func redirectionHandler(_ redirectionHandler: any RedirectionHandler) async -> Self {
        await state.set(redirectionHandler, to: \.handlers.redirectionHandler)
        return self
    }
    
    public func statusValidator(_ statusValidator: any StatusValidator) async -> Self {
        await state.set(statusValidator, to: \.handlers.statusValidator)
        return self
    }
    public func validate(
        for statuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: (@Sendable (_ status: ResponseStatus, _ task: any NetworkingTask) async -> (any Error)?)? = nil
    ) async -> Self {
        let statusValidator = DefaultStatusValidator(
                validStatuses: statuses,
                handler
            )
        await state.set(statusValidator, to: \.handlers.statusValidator)
        return self
    }
}
