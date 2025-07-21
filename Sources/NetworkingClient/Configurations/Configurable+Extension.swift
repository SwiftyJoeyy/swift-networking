//
//  Configurable+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 21/07/2025.
//

import Foundation
import NetworkingCore

extension Configurable {
    /// Enables or disables request/response logging.
    public func enableLogs(_ enabled: Bool = true) -> Self {
        return configuration(\.logsEnabled, enabled)
    }
    
    /// Sets the validator used to validate response statuses.
    ///
    /// Use this method to attach a custom ``StatusValidator``.
    ///
    /// - Parameter validator: The validator to apply.
    public func validate(_ validator: some StatusValidator) -> Self {
        return configuration(\.statusValidator, validator)
    }
    
    /// Disables response status validation.
    ///
    /// Use this to explicitly skip status validation for the request.
    public func unvalidated() -> Self {
        return configuration(\.statusValidator, nil)
    }
    
    /// Sets a default status validator with an optional validation handler.
    ///
    /// - Parameters:
    ///   - statuses: The set of acceptable statuses.
    ///   - handler: An optional closure for custom validation logic.
    public func validate(
        for statuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: DefaultStatusValidator.Handler? = nil
    ) -> Self {
        let validator = DefaultStatusValidator(
            validStatuses: statuses,
            handler
        )
        return validate(validator)
    }
    
    /// Sets the handler used to control how responses are cached.
    ///
    /// Use this method to attach a custom ``ResponseCacheHandler`` that decides
    /// whether a response should be cached, ignored, or modified before storing.
    ///
    /// You can return a predefined handler like ``DefaultResponseCacheHandler`` or
    /// use ``ResponseCacheHandler/none`` to disable caching.
    ///
    /// ```swift
    /// request.cacheHandler(MyCustomCacheHandler())
    /// ```
    ///
    /// - Parameter handler: The handler that manages caching for this request.
    public func cacheHandler(_ handler: some ResponseCacheHandler) -> Self {
        return configuration(\.cacheHandler, handler)
    }
    
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
    
    /// Sets the handler used to manage HTTP redirections.
    ///
    /// Use this method to override the default redirection behavior for a request.
    /// You can ignore, modify, or explicitly cancel redirects based on response metadata.
    ///
    /// - Parameter handler: A type conforming to ``RedirectionHandler``.
    ///
    /// - Note: Use ``RedirectionHandler/none`` to disable redirects.
    public func redirectionHandler(_ handler: some RedirectionHandler) -> Self {
        return configuration(\.redirectionHandler, handler)
    }
    
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
    
    /// Disables request authorization.
    ///
    /// Call this to explicitly disable authentication for a request.
    public func unauthorized() -> Self {
        return configuration(\.authInterceptor, nil)
    }
    
    /// Sets the authorization provider used to authorize requests.
    ///
    /// The interceptor will apply credentials before sending and refresh them
    /// automatically if the response is unauthorized.
    ///
    /// - Parameter provider: A type conforming to ``AuthProvider``.
    public func authorization(
        _ provider: some AuthProvider
    ) -> Self {
        return configuration(\.authInterceptor, AuthInterceptor(provider: provider))
    }
}
