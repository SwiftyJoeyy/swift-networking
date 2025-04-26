//
//  RetryPolicy.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

@frozen public enum RetryResult: Sendable {
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

public protocol RetryPolicy: Sendable {
    var maxRetryCount: Int {get}
    var retryableStatuses: Set<ResponseStatus> {get}
    
    func shouldRetry(
        _ task: some NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult
}

// MARK: - Default Implementations
extension RetryPolicy {
    public var retryableStatuses: Set<ResponseStatus> {
        return ResponseStatus.retryableStatuses
    }
    
    internal func _shouldRetry(
        _ task: some NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult {
        guard await task.retryCount < maxRetryCount else {
            return .doNotRetry
        }
        if let status, retryableStatuses.contains(status) {
            return .retry
        }
        return await shouldRetry(task, error: error, status: status)
    }
}

extension RetryPolicy where Self == DefaultRetryPolicy {
    public static var doNotRetry: Self {
        return DefaultRetryPolicy(maxRetryCount: 0)
    }
}

public struct DefaultRetryPolicy: RetryPolicy {
    public typealias Handler = @Sendable (
        _ error: (any Error)?,
        _ status: ResponseStatus?,
        _ task: any NetworkingTask
    ) async -> RetryResult
  
// MARK: - Properties
    public let maxRetryCount: Int
    public let retryableStatuses: Set<ResponseStatus>
    private let handler: Handler?
    
// MARK: - Initializer
    internal init(
        maxRetryCount: Int = 2,
        retryableStatuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        handler: Handler? = nil
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatuses = retryableStatuses
        self.handler = handler
    }
    
// MARK: - RetryPolicy
    public func shouldRetry(
        _ task: some NetworkingTask,
        error: (any Error)?,
        status: ResponseStatus?
    ) async -> RetryResult {
        return await handler?(error, status, task) ?? .doNotRetry
    }
}
