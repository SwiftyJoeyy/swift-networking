//
//  ConfigurationValues.swift
//  Networking
//
//  Created by Joe Maghzal on 17/04/2025.
//

import Foundation
import NetworkingCore

extension ConfigurationValues {
    /// Whether logs are enabled.
    @Config public internal(set) var logsEnabled = true
    
    /// The handler for managing HTTP redirections.
    @Config public internal(set) var redirectionHandler: any RedirectionHandler = DefaultRedirectionHandler()
    
    /// The validator used to validate HTTP response statuses.
    @Config public internal(set) var statusValidator: any StatusValidator = DefaultStatusValidator()
    
    /// The retry policy used for request retries.
    @Config public internal(set) var retryPolicy: any RetryPolicy = DefaultRetryPolicy()
    
    /// The cache handler used for managing response caching.
    @Config public internal(set) var cacheHandler: any ResponseCacheHandler = DefaultResponseCacheHandler()
    
    /// The interceptor used to modify or inspect requests before sending.
    @Config public internal(set) var interceptor: any RequestInterceptor = DefaultRequestInterceptor()
    
    /// The authentication handler used to refresh authorization credentials.
    @Config public internal(set) var authHandler: (any AuthenticationInterceptor)? = nil
    
    /// The task storage used to track and cancel network tasks.
    ///
    /// - Warning: If accessed before being explicitly set, this property will trigger a runtime
    /// precondition failure to help catch misconfiguration.
    @Config(forceUnwrapped: true) public internal(set) var tasks: any TasksStorage
}


extension Configurable {
    /// Enables or disables request/response logging.
    public func enableLogs(_ enabled: Bool = true) -> Self {
        return configuration(\.logsEnabled, enabled)
    }
    
    /// Sets the interceptor used to intercept requests before they are executed.
    public func interceptor(_ interceptor: some RequestInterceptor) -> Self {
        return configuration(\.interceptor, interceptor)
    }
    
    /// Sets the interceptor used to intercept requests before they are executed.
    public func onRequest(
        _ handler: @escaping DefaultRequestInterceptor.Handler
    ) -> Self {
        return interceptor(DefaultRequestInterceptor(handler))
    }
    
    /// Sets the retry policy to use when a request fails..
    public func retryPolicy(_ retryPolicy: some RetryPolicy) -> Self {
        return configuration(\.retryPolicy, retryPolicy)
    }
    
    /// Sets the retry policy to use when a request fails..
    ///
    /// - Parameters:
    ///   - limit: Maximum number of retry attempts.
    ///   - statuses: A set of response statuses for which retries should be attempted.
    ///   - handler: An optional custom retry decision handler.
    public func retry(
        limit: Int,
        for statuses: Set<ResponseStatus> = [],
        handler: DefaultRetryPolicy.Handler? = nil
    ) -> Self {
        let policy = DefaultRetryPolicy(
            maxRetryCount: limit,
            retryableStatuses: statuses,
            handler: handler
        )
        return retryPolicy(policy)
    }
    
    /// Sets the handler used for managing response caching.
    public func cacheHandler(_ handler: some ResponseCacheHandler) -> Self {
        return configuration(\.cacheHandler, handler)
    }
    
    /// Sets the handler for managing HTTP redirections.
    public func redirectionHandler(_ handler: some RedirectionHandler) -> Self {
        return configuration(\.redirectionHandler, handler)
    }
    
    /// Sets the validator used to validate HTTP response statuses.
    public func statusValidator(_ validator: some StatusValidator) -> Self {
        return configuration(\.statusValidator, validator)
    }
    
    /// Sets the validator used to validate HTTP response statuses.
    ///
    /// - Parameters:
    ///   - statuses: A set of valid response statuses.
    ///   - handler: An optional closure executed when a status needs validation.
    public func validate(
        for statuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: DefaultStatusValidator.Handler? = nil
    ) -> Self {
        let validator = DefaultStatusValidator(
            validStatuses: statuses,
            handler
        )
        return statusValidator(validator)
    }
    
    /// Sets the handler used to manage request authorization.
    public func authorization(
        _ interceptor: some AuthenticationInterceptor
    ) -> Self {
        return configuration(\.authHandler, interceptor)
    }
}
