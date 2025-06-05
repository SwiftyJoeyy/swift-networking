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
    @Config public internal(set) var statusValidator: (any StatusValidator)? = DefaultStatusValidator()
    
    /// The retry policy used for request retries.
    @Config public internal(set) var retryPolicy: (any RetryInterceptor)? = DefaultRetryInterceptor()
    
    /// The cache handler used for managing response caching.
    @Config public internal(set) var cacheHandler: any ResponseCacheHandler = DefaultResponseCacheHandler()
    
    /// The interceptor used to modify or inspect requests before sending.
    @Config public internal(set) var interceptor: (any RequestInterceptor)? = nil
    
    /// The authentication handler used to refresh authorization credentials.
    @Config public internal(set) var authInterceptor: AuthInterceptor? = nil
    
    /// The task storage used to track and cancel network tasks.
    ///
    /// - Warning: If accessed before being explicitly set, this property will trigger a runtime
    /// precondition failure to help catch misconfiguration.
    @Config(forceUnwrapped: true) public internal(set) var tasks: any TasksStorage
    
    /// The interceptors that will intercept the request & response.
    @Config internal var taskInterceptor: any Interceptor = TaskInterceptor()
}

extension Configurable {
    /// Enables or disables request/response logging.
    public func enableLogs(_ enabled: Bool = true) -> Self {
        return configuration(\.logsEnabled, enabled)
    }
}
