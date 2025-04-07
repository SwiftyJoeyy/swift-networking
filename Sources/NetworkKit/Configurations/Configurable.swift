//
//  Configurable.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// Requirement for types that can be configured using ``ConfigurationValues``.
///
/// Conforming types provide a way to set configuration values using key paths.
public protocol Configurable {
    /// Applies a configuration value to the given key path.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into the ``ConfigurationValues``.
    ///   - value: The value to assign to the given key path.
    func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self
}

extension Configurable {
    /// Sets the base URL for the request.
    public func url(_ url: URL?) -> Self {
        return configuration(\.url, url)
    }
    
    /// Sets the base URL for the request from a string.
    public func url(_ url: String) -> Self {
        return configuration(\.url, URL(string: url))
    }
    
    /// Sets the ``JSONEncoder`` used for encoding requests.
    public func encode(with encoder: JSONEncoder) -> Self {
        return configuration(\.encoder, encoder)
    }
    
    /// Sets the ``JSONDecoder`` used for decoding responses.
    public func decode(with decoder: JSONDecoder) -> Self {
        return configuration(\.decoder, decoder)
    }
    
    /// Enables or disables request/response logging.
    public func enableLogs(_ enabled: Bool = true) -> Self {
        return configuration(\.logsEnabled, enabled)
    }
}

// MARK: - Handlers
extension Configurable {
    /// Sets the interceptor used to intercept requests before they are executed.
    public func interceptor(_ interceptor: some RequestInterceptor) -> Self {
        return configuration(\.interceptor, interceptor)
    }
    
    /// Sets the interceptor used to intercept requests before they are executed.
    public func onRequest(
        _ handler: @escaping DefaultRequestInterceptor.Handler
    ) -> Self {
        return configuration(\.interceptor, DefaultRequestInterceptor(handler))
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
        let retryPolicy = DefaultRetryPolicy(
            maxRetryCount: limit,
            retryableStatuses: statuses,
            handler: handler
        )
        return configuration(\.retryPolicy, retryPolicy)
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
        let statusValidator = DefaultStatusValidator(
            validStatuses: statuses,
            handler
        )
        return configuration(\.statusValidator, statusValidator)
    }
    
    /// Sets the handler used to manage request authorization.
    public func authorization(
        _ interceptor: some AuthenticationInterceptor
    ) -> Self {
        return configuration(\.authHandler, interceptor)
    }
}
