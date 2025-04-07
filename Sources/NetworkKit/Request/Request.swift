//
//  Request.swift
//  NetworkKit
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
public protocol Request: _Request {
    /// The contents of the request.
    associatedtype Contents: Request
    
    /// An optional identifier for the request.
    var id: String? {get}
    
    /// The contents of the request.
    var request: Self.Contents {get}
    
    /// All request modifiers applied to this request.
    var allModifiers: [any RequestModifier] {get}
}

// MARK: - _Request
extension Request {
    /// An optional identifier for the request.
    public var id: String? {
        return String(describing: Self.self)
    }
    
    /// Constructs a ``URLRequest`` using the given base url.
    ///
    /// - Parameter baseURL: The base URL to use if the request does not have one.
    /// - Returns: The configured ``URLRequest``.
    public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        var configuredRequest = request
        configuredRequest._modifiers.append(contentsOf: _modifiers)
        return try configuredRequest._makeURLRequest(configurations)
    }
    
    /// All request modifiers applied to this request, including any
    /// inherited from its contained request.
    public var allModifiers: [any RequestModifier] {
        return _modifiers + request.allModifiers
    }
}
