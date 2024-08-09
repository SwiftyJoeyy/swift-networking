//
//  File.swift
//  
//
//  Created by Joe Maghzal on 15/06/2024.
//

import Foundation

public protocol RetryPolicy: ClientCommand {
    var maxRetryCount: Int {get}
    var retryableStatuses: [ResponseStatus] {get}
    func shouldRetry(_ request: some Request, error: Error?, status: ResponseStatus?) -> RetryResult
}

//MARK: - Default Implementations
extension RetryPolicy {
    public var maxRetryCount: Int {
        return 2
    }
    public var retryableStatuses: [ResponseStatus] {
        return [
            .requestTimeout,
            .internalServerError,
            .badGateway,
            .serviceUnavailable,
            .gatewayTimeout,
            .insufficientStorage
        ]
    }
}

extension RetryPolicy {
    public func execute(request: some Request, with context: Context) async -> Context {
        guard let error = context.result?.error else {
            return context
        }
        
        let reachedMaxRetries = context.currentRetryCount < maxRetryCount
        guard !reachedMaxRetries else {
            return context
        }
        
        let retryableStatusCode = context.statusCode.map({retryableStatuses.contains($0)}) ?? false
        guard retryableStatusCode else {
            return context
        }
        
        let retryResult = shouldRetry(
            request,
            error: error,
            status: context.statusCode
        )
        guard retryResult.shouldRetry else {
            return context
        }
        
        if let delay = retryResult.delay {
            try? await Task.sleep(nanoseconds: delay.nanoSeconds)
        }
        return context.retry()
    }
}

public enum RetryResult {
    case retry
    case waitAndRetry(TimeInterval)
    case doNotRetry
    
    internal var delay: TimeInterval? {
        switch self {
            case .waitAndRetry(let timeInterval):
                return timeInterval
            default:
                return nil
        }
    }
    
    internal var shouldRetry: Bool {
        switch self {
            case .waitAndRetry, .retry:
                return true
            default:
                return false
        }
    }
}

public struct DefaultRetryPolicy: RetryPolicy {
    public typealias RetryHandler = (_ error: Error?, _ status: ResponseStatus?) -> RetryResult
    public var handler: RetryHandler?
    public var maxRetryCount = 2
    public var retryableStatuses: [ResponseStatus] = [
        .requestTimeout,
        .internalServerError,
        .badGateway,
        .serviceUnavailable,
        .gatewayTimeout,
        .insufficientStorage
    ]
    
    public func shouldRetry(_ request: some Request, error: Error?, status: ResponseStatus?) -> RetryResult {
        return handler?(error, status) ?? .retry
    }
}
