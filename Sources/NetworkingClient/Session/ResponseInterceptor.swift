//
//  ResponseInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

/// A type that inspects and handles the response after a request completes.
///
/// Use a `ResponseInterceptor` to perform validation, retry logic,
/// error handling, or logging after a request has been executed.
///
/// Response interceptors are evaluated in order, and each returns
/// a ``RequestContinuation`` value that controls the request flow.
///
/// Attach a response interceptor using a request modifier or via configuration.
///
/// ```swift
/// struct MyValidator: ResponseInterceptor {
///     func intercept(
///         _ task: some NetworkingTask,
///         for session: Session,
///         with context: Context
///     ) async throws(NetworkingError) -> RequestContinuation {
///         if context.status?.isSuccess == false {
///             return .failure(MyError.badStatus)
///         }
///         return .continue
///     }
/// }
/// ```
public protocol ResponseInterceptor: Sendable {
    /// The context passed to each response interceptor.
    typealias Context = InterceptorContext
    
    /// Intercepts the response and decides how the request should proceed.
    ///
    /// - Parameters:
    ///   - task: The task associated with the request.
    ///   - session: The session executing the request.
    ///   - context: The response context, including status and error info.
    ///
    /// - Returns: A ``RequestContinuation`` indicating what to do next.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws(NetworkingError) -> RequestContinuation
}

/// A control flow value returned by a ``ResponseInterceptor`` to determine what happens next.
public enum RequestContinuation: Sendable {
    /// Continue to the next interceptor or finish successfully.
    ///
    /// Use this when no error was found and the response is acceptable.
    case `continue`
    
    /// Fail the request and return the given error.
    ///
    /// Use this when validation fails or the response is unacceptable.
    case failure(any Error)
    
    /// Retry the request from the beginning.
    ///
    /// Use this when a recoverable condition (like an expired token) was handled.
    case retry
}

/// Context passed to a ``ResponseInterceptor`` during evaluation.
///
/// This structure provides metadata about the completed request,
/// including configuration, response status, retry count, error state,
/// and the originating ``URLRequest``.
public struct InterceptorContext: Sendable {
    /// The configurations resolved for the request and task.
    public let configurations: ConfigurationValues
    
    /// The HTTP status of the response, if available.
    public let status: ResponseStatus?
    
    /// The number of times the request has been retried.
    public let retryCount: Int
    
    /// The original `URLRequest` used to perform the request.
    public let urlRequest: URLRequest?
    
    /// The error received when executing the request.
    ///
    /// This value is set only if the request failed.
    public var error: NetworkingError?
    
    /// The continuation result from the previous interceptor in the chain.
    ///
    /// Defaults to ``RequestContinuation/continue``.
    public var continuation = RequestContinuation.continue
}
