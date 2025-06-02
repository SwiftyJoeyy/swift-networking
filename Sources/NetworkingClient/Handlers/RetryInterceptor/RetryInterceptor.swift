//
//  RetryPolicy.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

@frozen public enum RetryResult: Sendable {
    case retry(delay: TimeInterval? = nil)
    case doNotRetry
    
    public var shouldRetry: Bool {
        switch self {
            case .retry:
                return true
            default:
                return false
        }
    }
    public var delay: TimeInterval? {
        switch self {
            case .retry(let delay):
                return delay
            default:
                return nil
        }
    }
}

public protocol RetryInterceptor: ResponseInterceptor {
    func shouldRetry(
        _ task: some NetworkingTask,
        error: any Error,
        with context: borrowing Context
    ) async -> RetryResult
}

extension RetryInterceptor {
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
    /// Sets the retry policy to use when a request fails..
    public func retry(_ interceptor: some RetryInterceptor) -> Self {
        return configuration(\.retryPolicy, interceptor)
    }
    
    /// Sets the retry policy to use when a request fails..
    public func doNotRetry() -> Self {
        return configuration(\.retryPolicy, nil)
    }
    
    /// Sets the retry policy to use when a request fails..
    ///
    /// - Parameters:
    ///   - limit: Maximum number of retry attempts.
    ///   - statuses: A set of response statuses for which retries should be attempted.
    ///   - handler: An optional custom retry decision handler.
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
    
    /// Sets the retry policy to use when a request fails..
    ///
    /// - Parameters:
    ///   - limit: Maximum number of retry attempts.
    ///   - statuses: A set of response statuses for which retries should be attempted.
    ///   - handler: An optional custom retry decision handler.
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
    
    /// Sets the retry policy to use when a request fails..
    ///
    /// - Parameters:
    ///   - limit: Maximum number of retry attempts.
    ///   - statuses: A set of response statuses for which retries should be attempted.
    ///   - handler: An optional custom retry decision handler.
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
