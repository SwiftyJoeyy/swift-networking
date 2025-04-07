//
//  Configurations.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// A configuration key used to store configurations in ``ConfigurationValues``.
public protocol ConfigurationKey {
    /// The type of value associated with this key.
    associatedtype Value: Sendable
    
    /// The default value to use if no value is set in `ConfigurationValues`.
    static var defaultValue: Self.Value {get}
}

/// Container for storing and accessing type-safe configuration values.
///
/// This type holds a collection of values indexed by their ``ConfigurationKey`` type.
/// Each key has a default value that is used if a custom value is not provided.
public struct ConfigurationValues: Sendable {
    /// The configuration values storage.
    private var values = [ObjectIdentifier: any Sendable]()
    
    /// Accesses the value associated with the given configuration key type.
    ///
    /// If a value has been previously set for the key, it is returned. Otherwise,
    /// the key's default value is returned.
    ///
    /// - Parameter key: The type of the configuration key.
    public subscript<Key: ConfigurationKey>(_ key: Key.Type) -> Key.Value {
        get {
            guard let value = values[ObjectIdentifier(key)] else {
                return Key.defaultValue
            }
            return unsafeBitCast(value, to: Key.Value.self)
        }
        set {
            values[ObjectIdentifier(key)] = newValue
        }
    }
}

extension ConfigurationValues {
    /// The decoder used for decoding responses.
    @Config public var decoder = JSONDecoder()
    
    /// The encoder used for encoding requests.
    @Config public var encoder = JSONEncoder()
    
    /// The base URL used in requests.
    @Config public var url: URL? = nil
    
    /// Whether logs are enabled.
    @Config public var logsEnabled = true
    
    /// The handler for managing HTTP redirections.
    @Config public var redirectionHandler: any RedirectionHandler = DefaultRedirectionHandler()
    
    /// The validator used to validate HTTP response statuses.
    @Config public var statusValidator: any StatusValidator = DefaultStatusValidator()
    
    /// The retry policy used for request retries.
    @Config public var retryPolicy: any RetryPolicy = DefaultRetryPolicy()
    
    /// The cache handler used for managing response caching.
    @Config public var cacheHandler: any ResponseCacheHandler = DefaultResponseCacheHandler()
    
    /// The interceptor used to modify or inspect requests before sending.
    @Config public var interceptor: any RequestInterceptor = DefaultRequestInterceptor()
    
    /// The authentication handler used to refresh authorization credentials.
    @Config public var authHandler: (any AuthenticationInterceptor)? = nil
    
    /// The task storage used to track and cancel network tasks.
    ///
    /// If accessed before being explicitly set, this property will trigger a runtime
    /// precondition failure to help catch misconfiguration.
    public var tasks: any TasksStorage {
        get {
            let value = self[TasksConfigurationKey.self]
            precondition(
                value != nil,
                "Missing configuration of type: 'any TasksStorage'. Make sure you're setting a value for the key 'tasks' before using it."
            )
            return value!
        }
        set {
            self[TasksConfigurationKey.self] = newValue
        }
    }
}

fileprivate struct TasksConfigurationKey: ConfigurationKey {
    static let defaultValue: (any TasksStorage)? = nil
}
