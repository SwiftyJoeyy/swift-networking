//
//  DefaultRetryInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

/// A retry policy that supports count limits, response filtering, and delay strategies.
///
/// Use `DefaultRetryInterceptor` to automatically retry requests
/// that fail under certain conditions. It supports:
///
/// - A maximum number of retry attempts
/// - A set of retryable response statuses
/// - Custom retry timing strategies
/// - Optional logic for custom conditions
///
/// Attach it using ``Configurable/retry(limit:for:strategy:handler:)``
/// or one of the other retry configuration methods.
public struct DefaultRetryInterceptor: RetryInterceptor {
    /// A custom handler that determines whether to retry for a given error.
    ///
    /// This closure is evaluated after the retry count and status checks pass.
    /// Return `false` to cancel the retry even if other conditions are met.
    public typealias Handler = @Sendable (
        _ task: any NetworkingTask,
        _ error: NetworkingError,
        _ context: borrowing Context
    ) async -> Bool
    
    /// The maximum number of retry attempts.
    private let maxRetryCount: Int
    
    /// A set of status codes that are eligible for retry.
    private let retryableStatuses: Set<ResponseStatus>
    
    /// The strategy that determines delay timing between retries.
    private let strategy: RetryStrategy
    
    /// An optional handler used to override retry decisions.
    private let handler: Handler?
    
    /// Creates a retry interceptor with the specified policy and behavior.
    ///
    /// - Parameters:
    ///   - maxRetryCount: The maximum number of retry attempts. Defaults to `2`.
    ///   - retryableStatuses: The set of status codes that are eligible for retry.
    ///   - strategy: The strategy that determines delay timing between retries.
    ///   - handler: An optional closure to override retry decisions.
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
    
    /// Evaluates whether the request should be retried based on the current context.
    ///
    /// This implementation checks:
    /// - Whether the retry count is below the limit
    /// - Whether the response status is retryable (if present)
    /// - Whether the handler allows retrying
    ///
    /// If all conditions pass, a delay may be applied based on the strategy.
    public func shouldRetry(
        _ task: some NetworkingTask,
        error: NetworkingError,
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
    /// A strategy that determines how to delay retries between attempts.
    ///
    /// Use a retry strategy to introduce controlled wait periods between retry attempts.
    /// This helps prevent flooding, manage rate limits, and support backoff logic.
    public enum RetryStrategy: Sendable {
        /// Retry immediately without delay.
        case instant
        
        /// Use a fixed delay between each retry attempt.
        ///
        /// - Parameter delay: The number of seconds to wait between retries.
        case fixed(TimeInterval)
        
        /// Use exponential backoff with optional jitter.
        ///
        /// Each retry multiplies the base delay using the specified multiplier.
        ///
        /// - Parameters:
        ///   - base: The initial delay before the first retry.
        ///   - multiplier: The factor used to increase delay on each attempt.
        ///   - jitter: Whether to randomize the delay to prevent burst retries.
        case exponential(base: TimeInterval, multiplier: Double, jitter: Bool)
        
        /// Returns the computed delay based on the retry count.
        ///
        /// - Parameter retryCount: The number of previous attempts.
        /// - Returns: The delay in seconds, or `nil` for immediate retry.
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
