//
//  RetryInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

/// A value that determines whether a failed request should be retried.
///
/// Use this value to indicate whether the request should be attempted again
/// and whether a delay should be applied before retrying.
///
/// Returned from ``RetryInterceptor/shouldRetry(_:error:with:)``.
@frozen public enum RetryResult: Sendable {
    /// Retry the request. An optional delay can be applied before the retry.
    case retry(delay: TimeInterval? = nil)
    
    /// Do not retry the request.
    case doNotRetry
    
    /// Whether the request should be retried.
    public var shouldRetry: Bool {
        switch self {
            case .retry:
                return true
            default:
                return false
        }
    }
    
    /// The delay before retrying the request, if any.
    public var delay: TimeInterval? {
        switch self {
            case .retry(let delay):
                return delay
            default:
                return nil
        }
    }
}

/// A type that determines whether a failed request should be retried.
///
/// Conform to ``RetryInterceptor`` to evaluate a failure and return
/// a ``RetryResult`` indicating whether the request should be retried
/// and after how long.
///
/// You can attach a retry interceptor using ``Configurable/retry(_:)``.
public protocol RetryInterceptor: ResponseInterceptor {
    /// Determines whether to retry a failed request.
    ///
    /// - Parameters:
    ///   - task: The current networking task.
    ///   - error: The error that caused the failure.
    ///   - context: The request context at the time of failure.
    ///
    /// - Returns: A ``RetryResult`` that determines whether to retry.
    func shouldRetry(
        _ task: some NetworkingTask,
        error: any Error,
        with context: borrowing Context
    ) async -> RetryResult
}

extension RetryInterceptor {
    /// Evaluates the retry policy for a failed request.
    ///
    /// If the context contains an error and the response is not unauthorized,
    /// this method calls ``RetryInterceptor/shouldRetry(_:error:with:)`` and returns
    /// `.retry` or `.continue`, depending on the result.
    public func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws -> RequestContinuation {
        guard context.status != .unauthorized,
              let error = context.error
        else {
            return .continue
        }
        let result = await shouldRetry(task, error: error, with: context)
        guard result.shouldRetry else {
            return .continue
        }
        
        if let delay = result.delay {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
            }catch {
                throw error
            }
        }
        return .retry
    }
}

extension Configurable {
    /// Sets the retry policy to use when a request fails.
    ///
    /// Use this method to apply a custom retry strategy using a type
    /// that conforms to ``RetryInterceptor``.
    public func retry(_ interceptor: some RetryInterceptor) -> Self {
        return configuration(\.retryPolicy, interceptor)
    }
    
    /// Disables retry behavior for the request.
    ///
    /// Call this method to explicitly opt out of retry logic.
    public func doNotRetry() -> Self {
        return configuration(\.retryPolicy, nil)
    }
    
    /// Sets the retry policy using a retry limit, retryable statuses, and strategy.
    ///
    /// This overload lets you specify a maximum retry count and a strategy such as
    /// `.instant`, `.fixed`, or `.exponential`.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of retry attempts.
    ///   - statuses: The set of status codes that are eligible for retry.
    ///   - strategy: The timing strategy to use for scheduling retries.
    ///   - handler: An optional handler for custom retry decisions.
    public func retry(
        limit: Int = 2,
        for statuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        strategy: DefaultRetryInterceptor.RetryStrategy = .instant,
        handler: DefaultRetryInterceptor.Handler? = nil
    ) -> Self {
        let interceptor = DefaultRetryInterceptor(
            maxRetryCount: limit,
            retryableStatuses: statuses,
            strategy: strategy,
            handler: handler
        )
        return retry(interceptor)
    }
    
    /// Sets the retry policy with a fixed delay between attempts.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of retry attempts.
    ///   - statuses: The status codes that are eligible for retry.
    ///   - delay: The delay in seconds between attempts.
    ///   - handler: An optional custom decision handler.
    public func retry(
        limit: Int = 2,
        for statuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        delay: TimeInterval,
        handler: DefaultRetryInterceptor.Handler? = nil
    ) -> Self {
        return retry(
            limit: limit,
            for: statuses,
            strategy: .fixed(delay),
            handler: handler
        )
    }
    
    /// Sets the retry policy with exponential backoff between attempts.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of retry attempts.
    ///   - statuses: The status codes that are eligible for retry.
    ///   - base: The base delay for the first retry.
    ///   - multiplier: The multiplier applied to each successive retry.
    ///   - jitter: Whether to randomize the delay with jitter.
    ///   - handler: An optional custom decision handler.
    public func retry(
        limit: Int = 2,
        for statuses: Set<ResponseStatus> = ResponseStatus.retryableStatuses,
        base: TimeInterval,
        multiplier: Double,
        jitter: Bool = false,
        handler: DefaultRetryInterceptor.Handler? = nil
    ) -> Self {
        return retry(
            limit: limit,
            for: statuses,
            strategy: .exponential(base: base, multiplier: multiplier, jitter: jitter),
            handler: handler
        )
    }
}
