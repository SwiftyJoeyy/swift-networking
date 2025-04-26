//
//  HTTPRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 1/17/25.
//

import Foundation

/// HTTP request that can be customized with various modifiers.
/// Use this as a base structure to define network requests.
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
@frozen public struct HTTPRequest {
    /// The request's identifier.
    public let id = "HTTPRequest"
    
    /// The base URL for the request.
    private let url: URL?
    
    /// The request modifiers applied to this request.
    public var _modifiers = [any RequestModifier]()
    
    /// Creates a new ``HTTPRequest`` to be used for calling apis.
    ///
    /// - Parameters:
    ///  - url: The base URL of the request.
    ///  - path: The path to append to the base URL.
    ///  - components: A builder closure that returns request modifiers.
    public init(
        url: URL? = nil,
        path: String? = nil,
        @RequestModifiersBuilder components: () -> [any RequestModifier] = {[ ]}
    ) {
        self.url = url
        self._modifiers = components()
        if let path {
            _modifiers.append(PathRequestModifier([path]))
        }
    }
    
    /// Creates a new ``HTTPRequest`` to be used for calling apis.
    ///
    /// - Parameters:
    ///  - url: The base URL of the request.
    ///  - path: The path to append to the base URL.
    ///  - components: A builder closure that returns request modifiers.
    @inlinable public init(
        url: String,
        path: String? = nil,
        @RequestModifiersBuilder components: () -> [any RequestModifier] = {[ ]}
    ) {
        self.init(
            url: URL(string: url),
            path: path,
            components: components
        )
    }
}

// MARK: - Request
extension HTTPRequest: Request {
    public typealias Contents = Never
    
    /// Constructs a ``URLRequest`` using the given base url.
    ///
    /// - Parameter baseURL: The base URL to use if the request does not have one.
    /// - Returns: The configured ``URLRequest``.
    public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        let baseURL = configurations.baseURL
        guard let url = url ?? baseURL else {
            throw NetworkingError.invalidRequestURL
        }
        var request = URLRequest(url: url)
        
        for component in _modifiers {
            request = try component.modifying(
                consume request,
                with: configurations
            )
        }
        return request
    }
}
