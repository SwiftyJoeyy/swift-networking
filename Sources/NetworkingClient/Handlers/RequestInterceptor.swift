//
//  RequestInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation
import NetworkingCore

/// A type that intercepts and modifies a ``URLRequest`` before it is sent.
///
/// Prefer using composable request types for static or synchronous request modification.
/// Interceptors should be used for asynchronous or heavyweight operations that cannot
/// be expressed through composable APIs.
///
/// For simple header injection or static query mutation, prefer defining a reusable
/// ``Request`` or a ``RequestModifier`` instead.
///
/// Use a ``RequestInterceptor`` to inspect, rewrite, or replace an outgoing request
/// before it's executed. This can be useful for:
///
/// - Adding dynamic authentication headers
/// - Re-signing the request at runtime
/// - Fetching data from secure storage
///
/// Interceptors are applied after all request modifiers and configuration values
/// are resolved. You can set an interceptor using ``Configurable/onRequest(_:)``.
///
/// - Important: Interceptors are **async** and can perform asynchronous work,
/// such as reading from disk or querying a token store.
public protocol RequestInterceptor: Sendable {
    /// Intercepts the outgoing request and returns a modified version.
    ///
    /// - Parameters:
    ///   - task: The task associated with this request.
    ///   - request: The original ``URLRequest`` produced by the request modifiers.
    ///   - session: The session that will execute the request.
    ///   - configurations: The current resolved configuration values.
    ///
    /// - Returns: The modified or replaced request to be executed.
    func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest
}

/// A default implementation of ``RequestInterceptor`` using a closure.
///
/// Use this type when you want to intercept a request with a one-off closure
/// instead of defining a custom interceptor type.
///
/// This is ideal for scenarios where request modification depends on runtime state,
/// such as secure token fetching, disk access, or environment-driven behavior.
///
/// - Important: Avoid using interceptors for simple or synchronous tasks,
/// create reusable ``Request`` or a ``RequestModifier`` instead.
///
/// ```swift
/// task.onRequest { request, task, session, config in
///     var modified = request
///     modified.setValue("Bearer \(await tokenStore.fetch())", forHTTPHeaderField: "Authorization")
///     return modified
/// }
/// ```
public struct DefaultRequestInterceptor: RequestInterceptor {
    /// A closure that performs request interception.
    public typealias Handler = @Sendable (
        _ request: URLRequest,
        _ task: any NetworkingTask,
        _ session: Session,
        _ configurations: ConfigurationValues
    ) async throws -> URLRequest
    
    /// The handler used to modify requests.
    private let handler: Handler
    
    /// Creates a new request interceptor from a handler.
    ///
    /// - Parameter handler: A closure that returns a modified request.
    public init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    
    /// Calls the handler to modify the request.
    public func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest {
        do {
            return try await handler(consume request, task, session, configurations)
        }catch {
            throw error.networkingError
        }
    }
}

extension Configurable {
    /// Sets the interceptor used to modify the request before execution.
    ///
    /// Prefer using composable request types for static or synchronous request modification.
    /// Interceptors should be used for asynchronous or heavyweight operations that cannot
    /// be expressed through composable APIs.
    ///
    /// For simple header injection or static query mutation, prefer defining a reusable
    /// ``Request`` or a ``RequestModifier`` instead.
    ///
    /// Use this method to attach a custom type conforming to ``RequestInterceptor``.
    ///
    /// - Parameter interceptor: A type that intercepts outgoing requests.
    public func onRequest(_ interceptor: some RequestInterceptor) -> Self {
        return configuration(\.interceptor, interceptor)
    }
    
    /// Sets a closure-based interceptor for outgoing requests.
    ///
    /// Prefer using composable request types for static or synchronous request modification.
    /// Interceptors should be used for asynchronous or heavyweight operations that cannot
    /// be expressed through composable APIs.
    ///
    /// For simple header injection or static query mutation, prefer defining a reusable
    /// ``Request`` or a ``RequestModifier`` instead.
    ///
    /// ```swift
    /// task.onRequest { request, task, session, config in
    ///     var modified = request
    ///     modified.setValue("Bearer \(await tokenStore.fetch())", forHTTPHeaderField: "Authorization")
    ///     return modified
    /// }
    /// ```
    ///
    /// - Parameter handler: A closure that modifies the request.
    public func onRequest(
        _ handler: @escaping DefaultRequestInterceptor.Handler
    ) -> Self {
        return onRequest(DefaultRequestInterceptor(handler))
    }
}
