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
public protocol Request: CustomStringConvertible {
    /// The contents of the request.
    associatedtype Contents: Request
    
    /// The request's identifier.
    var id: String {get}
    
    /// The contents of the request.
    var request: Self.Contents {get}
    
    /// Constructs a ``URLRequest`` from this ``HTTPRequest``
    /// and the provided configuration context.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Parameter configurations: The context in which to evaluate the request, including
    ///   fallback values like ``ConfigurationValues/baseURL``.
    /// - Returns: The configured ``URLRequest``.
    func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest
}

extension Request {
    /// The request's identifier.
    public var id: String {
        return String(describing: Self.self)
    }
    
    /// Constructs a ``URLRequest`` from this ``HTTPRequest``
    /// and the provided configuration context.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Parameter configurations: The context in which to evaluate the request, including
    ///   fallback values like ``ConfigurationValues/baseURL``.
    /// - Returns: The configured ``URLRequest``.
    @inlinable public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        return try request._makeURLRequest(configurations)
    }
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
