//
//  DefaultRetryInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation

public struct DefaultRetryInterceptor: RetryInterceptor {
    public typealias Handler = @Sendable (
        _ task: any NetworkingTask,
        _ error: any Error,
        _ context: borrowing Context
    ) async -> Bool
    
    private let maxRetryCount: Int
    private let retryableStatuses: Set<ResponseStatus>
    private let strategy: RetryStrategy
    private let handler: Handler?
    
    public init(
        maxRetryCount: Int = 2,
        retryableStatuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        strategy: RetryStrategy = .instant,
        handler: Handler? = nil
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatuses = retryableStatuses
        self.strategy = strategy
        self.handler = handler
    }
    
    public func shouldRetry(
        _ task: some NetworkingTask,
        error: any Error,
        with context: borrowing Context
    ) async -> RetryResult {
        let retryCount = context.retryCount
        guard retryCount < maxRetryCount else {
            return .doNotRetry
        }
        
        if let status = context.status, !retryableStatuses.contains(status) {
            return .doNotRetry
        }
        
        if let handler, !(await handler(task, error, context)) {
            return .doNotRetry
        }
        
        let delay = strategy.delay(after: Double(retryCount))
        return .retry(delay: delay)
    }
}

extension DefaultRetryInterceptor {
    public enum RetryStrategy: Sendable {
        case instant
        case fixed(TimeInterval)
        case exponential(base: TimeInterval, multiplier: Double, jitter: Bool)
        
        internal func delay(after retryCount: Double) -> TimeInterval? {
            switch self {
                case .instant:
                    return nil
                case .fixed(let delay):
                    return delay
                case .exponential(let base, let multiplier, let jitter):
                    let exponentialDelay = base * pow(multiplier, retryCount)
                    let jitterDelay = jitter ? Double.random(in: 0.8...1.2): 1
                    return exponentialDelay * jitterDelay
            }
        }
    }
}
