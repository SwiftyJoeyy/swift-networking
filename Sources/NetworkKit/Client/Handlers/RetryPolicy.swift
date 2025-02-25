//
//  RetryPolicy.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

public protocol RetryPolicy: Sendable {
    var maxRetryCount: Int {get}
    var retryableStatuses: Set<ResponseStatus> {get}
    
    func shouldRetry(
        _ task: any NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult
}

// MARK: - Default Implementations
extension RetryPolicy {
    public var maxRetryCount: Int {
        return 2
    }
    public var retryableStatuses: Set<ResponseStatus> {
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
    internal func _shouldRetry(
        _ task: any NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult {
        guard await task.retryCount < maxRetryCount else {
            return .doNotRetry
        }
        if let status, !retryableStatuses.isEmpty, !retryableStatuses.contains(status) {
            return .doNotRetry
        }
        return await shouldRetry(task, error: error, status: status)
    }
}

public enum RetryResult: Sendable {
    case retry
    case doNotRetry
    case delayedRetry(_ delay: TimeInterval)
    
    public var shouldRetry: Bool {
        switch self {
        case .retry, .delayedRetry:
            return true
        default:
            return false
        }
    }
    public var delay: TimeInterval? {
        switch self {
        case .delayedRetry(let delay):
            return delay
        default:
            return nil
        }
    }
}

internal struct DefaultRetryPolicy: RetryPolicy {
    internal let maxRetryCount: Int
    internal let retryableStatuses: Set<ResponseStatus>
    private let handler: (
        @Sendable (
            _ error: (any Error)?,
            _ status: ResponseStatus?,
            _ task: any NetworkingTask
        ) async -> RetryResult
    )?
    
    internal init(
        maxRetryCount: Int = 2,
        retryableStatuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        handler: (
            @Sendable (
                _ error: (any Error)?,
                _ status: ResponseStatus?,
                _ task: any NetworkingTask
            ) async -> RetryResult
        )? = nil
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatuses = retryableStatuses
        self.handler = handler
    }
    
    internal func shouldRetry(
        _ task: any NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult {
        return await handler?(error, status, task) ?? .retry
    }
}
