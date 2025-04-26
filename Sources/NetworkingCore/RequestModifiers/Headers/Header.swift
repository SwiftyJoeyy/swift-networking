//
//  Header.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A group of headers.
public typealias HeadersGroup = Header.Group

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
    public var headers: [String : String] {
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

extension Header {
    /// A group of headers.
    @frozen public struct Group: RequestHeader, Equatable, Hashable, Sendable {
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
        
        /// Creates a new ``HeadersGroup`` from an array of ``RequestHeader``.
        ///
        /// - Parameter headers: The request headers to be grouped.
        @inlinable public init(_ headers: [any RequestHeader]) {
            var headersFields = [String: String]()
            for header in headers.flatMap(\.headers) {
                headersFields[header.key] = header.value
            }
            self.init(headersFields)
        }
        
        /// Creates a new ``HeadersGroup`` using a builder closure for headers.
        ///
        /// - Parameter headers: A builder closure returning a ``HeadersGroup``.
        @inlinable public init(@HeadersBuilder _ headers: () -> HeadersGroup) {
            self = headers()
        }
    }
}
