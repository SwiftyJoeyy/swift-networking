//
//  Request.swift
//  Networking
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

/// Requirements for defining a network request.
///
/// When defining a request, always start with ``HTTPRequest`` as the base
/// structure. Extend its functionality by applying request modifiers to
/// customize headers, parameters, and other properties.
///
/// ```
/// @Request
/// struct GoogleRequest {
///     var request: some Request {
///         HTTPRequest(url: "https://www.google.com") {
///             JSON([
///                 "date": "1/16/2025"
///             ])
///         }.method(.get)
///         .cachePolicy(.returnCacheDataElseLoad)
///         .timeout(90)
///         .appending(paths: "v2", "search")
///     }
/// }
/// ```
///
/// You can use the ``Header`` & ``Parameter`` macros to define and add
/// HTTP headers & query parameters to a request in a concise and
/// readable manner, ensuring proper request configuration.
///
/// ```
/// @Request
/// struct GoogleRequest {
///     @Header("device") var device: String // Automatically applied.
///     @Parameter var language = "en"
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - Note: Base your requests on ``HTTPRequest``, do not manually
/// build the request using the private protocol requirements.
///
/// - Warning: Use the ``Request`` macro to define requests,
/// do not manually conform to this protocol.
public protocol Request: _DynamicConfigurable, CustomStringConvertible {
    /// The contents of the request.
    associatedtype Contents: Request
    
    /// The request's identifier.
    var id: String {get}
    
    /// The contents of the request.
    var request: Self.Contents {get}
    
    /// Constructs a ``URLRequest`` from this request
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Returns: The configured ``URLRequest``.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    @_spi(Internal) func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws -> URLRequest
}

extension Request {
    /// The request's identifier.
    public var id: String {
        return String(describing: Self.self)
    }
    
    /// Constructs a ``URLRequest`` from this request.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Returns: The configured ``URLRequest``.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    @_spi(Internal) public func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws -> URLRequest {
        var configs = consume configurations
        if configs.requestID == nil {
            configs[keyPath: \.requestID] = id
        }
        _accept(configs)
        return try request._makeURLRequest(with: configs)
    }
    
    /// Applies the given configuration values to the underlying request.
    ///
    /// This method forwards the provided ``ConfigurationValues`` to the
    /// encapsulated request. Use this to ensure the request is evaluated
    /// within the correct configuration context.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    @_spi(Internal) public func _accept(_ values: ConfigurationValues) { }
}

// MARK: - CustomStringConvertible
extension Request {
    public var description: String {
        return """
        \(String(describing: Self.self)) {
          id = \(id),
          request = \(String(describing: request))
        }
        """
    }
}
