//
//  HTTPRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 1/17/25.
//

import Foundation

/// HTTP request that can be customized with various modifiers.
///
/// ``HTTPRequest`` is a composable, generic structure used to define HTTP requests.
/// It supports configuration through request modifiers and can be initialized
/// with a base URL, a path, and additional modifiers such as headers, method, and body.
///
/// Use this as a base structure to construct HTTP requests.
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
/// - Note: If the base URL is not provided at initialization, it must be available
///   through ``ConfigurationValues.baseURL`` at the time of request execution.
@frozen public struct HTTPRequest<Modifier: RequestModifier> {
    /// The configuration values available to this instance.
    @Configurations private var configurations
    
    /// The request's identifier.
    public let id = "HTTPRequest"
    
    /// The base URL for the request.
    private let url: URL?
    
    /// An optional path to append to the base URL.
    private let path: String?
    
    /// The request modifier that defines the request’s behavior.
    private let modifier: Modifier
}

extension HTTPRequest {
    /// Creates a new ``HTTPRequest``  with an optional base url, path and modifiers..
    ///
    /// - Parameters:
    ///  - url: The base URL of the request.
    ///  - path: The path to append to the base URL.
    ///  - components: A builder that provides the request modifiers to apply.
    public init(
        url: URL? = nil,
        path: String? = nil,
        @ModifiersBuilder modifier: () -> Modifier = { EmptyModifier() }
    ) {
        self.url = url
        self.path = path
        self.modifier = modifier()
    }
    
    /// Creates a new ``HTTPRequest`` with an optional base url, path and modifiers..
    ///
    /// - Parameters:
    ///  - url: The base URL of the request.
    ///  - path: The path to append to the base URL.
    ///  - components: A result builder that provides the request modifiers to apply.
    @_disfavoredOverload @inlinable public init(
        url: String? = nil,
        path: String? = nil,
        @ModifiersBuilder modifier: () -> Modifier = { EmptyModifier() }
    ) {
        self.init(
            url: url.flatMap({URL(string: $0)}),
            path: path,
            modifier: modifier
        )
    }
}

// MARK: - Request
extension HTTPRequest: Request {
    /// Accessing this property will always result in a fatal error.
    ///
    /// - Warning: This should not be accessed directly.
    public var request: Never {
        fatalError("Should not be called directly!!")
    }
    
    /// Constructs a ``URLRequest`` from this ``HTTPRequest``.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Returns: The configured ``URLRequest``.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _makeURLRequest() throws -> URLRequest {
        let baseURL = configurations.baseURL
        guard let url = url ?? baseURL else {
            throw NetworkingError.invalidRequestURL
        }
        
        var urlRequest = URLRequest(url: url)
        if let path {
            urlRequest = try PathRequestModifier([path])
                .modifying(consume urlRequest)
        }
        
        return try modifier.modifying(consume urlRequest)
    }
    
    /// Applies the given configuration values to the request.
    ///
    /// This method forwards the provided ``ConfigurationValues`` to the associated
    /// request modifier and to this instance’s internal configuration storage.
    /// Use this to propagate inherited configuration values through the request
    /// chain.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        modifier._accept(values)
        _configurations._accept(values)
    }
}
