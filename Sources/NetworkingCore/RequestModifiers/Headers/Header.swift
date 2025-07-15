//
//  Header.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A HTTP header.
///
/// You can use the ``Header`` macro to define and add
/// HTTP headers to a request in a concise and
/// readable manner, ensuring proper request configuration.
///
/// ```
/// @Request
/// struct GoogleRequest {
///     @Header("device") var device: String // Automatically applied.
///     @Header var language = "en"
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
@frozen public struct Header: RequestHeader, Equatable, Hashable, Sendable {
    /// The header key.
    public var key: String
    
    /// The header value.
    public var value: String
    
    /// The header dictionary representation.
    public var headers: [String: String] {
        return [key: value]
    }
    
    /// Creates a new ``Header`` with a key and value.
    ///
    /// - Parameters:
    ///  - key: The header field name.
    ///  - value: The value of the header field.
    @inlinable public init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// A group of headers.
@frozen public struct HeadersGroup: RequestHeader, Equatable, Hashable, Sendable {
    /// The HTTP headers contained in this group.
    public var headers: [String: String]
    
    /// Creates a new ``HeadersGroup`` from a dictionary of headers.
    ///
    /// - Parameter headers: The headers dictionary.
    @inlinable public init(_ headers: [String: String]) {
        self.headers = headers
    }
    
    /// Creates a new ``HeadersGroup`` from a dictionary with optional values.
    ///
    /// - Parameter headers: The headers dictionary with optional values.
    @inlinable public init(_ headers: [String: String?]) {
        self.init(headers.compactMapValues(\.self))
    }
    
    /// Creates a new ``HeadersGroup`` using ``HeadersBuilder``.
    ///
    /// - Parameter header: A builder returning headers.
    @inlinable public init(
        @HeadersBuilder header: () -> some RequestHeader
    ) {
        self.init(header().headers)
    }
}

// MARK: - Modifier
extension Request {
    /// Adds an additional header to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .additionalHeader("language", value: "en")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - key: The header field name.
    ///  - value: The value of the header field.
    ///
    /// - Returns: A request with the additional headers applied.
    @inlinable public func additionalHeader(
        _ key: String,
        value: String?
    ) -> some Request {
        additionalHeaders {
            if let value {
                Header(key, value: value)
            }
        }
    }
}
