//
//  CommonHeaders.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// An `Accept-Language` HTTP header.
///
/// Specifies the preferred languages for the response. Commonly used for localization.
@frozen public struct AcceptLanguage: RequestHeader, Equatable, Hashable, Sendable {
    /// The language value.
    public var value: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Accept-Language": value]
    }
    
    //// Creates an `Accept-Language` header.
    ///
    /// - Parameter value: The language tag to apply (e.g. `"en-US"`).
    @inlinable public init(_ value: String) {
        self.value = value
    }
}

/// An `Accept-Encoding` HTTP header.
///
/// Specifies the content encoding types the client supports.
@frozen public struct AcceptEncoding: RequestHeader, Equatable, Hashable, Sendable {
    /// The encoding type.
    public var type: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Accept-Encoding": type]
    }
    
    /// Creates an `Accept-Encoding` header from a raw string.
    ///
    /// - Parameter type: The encoding value to apply.
    @inlinable public init(_ type: String) {
        self.type = type
    }
    
    /// Creates an `Accept-Encoding` header from a predefined encoding type.
    ///
    /// - Parameter type: A supported encoding type.
    @inlinable public init(_ type: EncodingType) {
        self.init(type.rawValue)
    }

    /// Common content encoding types.
    public enum EncodingType: String, Equatable, Hashable, Sendable, CaseIterable {
        /// `gzip`.
        case gzip = "gzip"
        
        /// `deflate`.
        case deflate = "deflate"
        
        /// `br`.
        case br = "br"
        
        /// `identity`.
        case identity = "identity"
    }
}

/// An `Accept` HTTP header.
///
/// Declares the content types the client is willing to receive from the server.
@frozen public struct Accept: RequestHeader, Equatable, Hashable, Sendable {
    /// The accepted content type
    public var type: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Accept": type]
    }
    
    /// Creates an `Accept` header from a raw value.
    ///
    /// - Parameter type: The content type string.
    @inlinable public init(_ type: String) {
        self.type = type
    }
    
    /// Creates an `Accept` header using a predefined content type.
    ///
    /// - Parameter type: A supported body content type.
    @inlinable public init(_ type: BodyContentType) {
        self.init(type.value)
    }
}

/// A `User-Agent` HTTP header.
///
/// Identifies the client software making the request, such as app name and version.
@frozen public struct UserAgent: RequestHeader, Equatable, Hashable, Sendable {
    /// The user agent.
    public var agent: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["User-Agent": agent]
    }
    
    /// Creates a `User-Agent` header.
    ///
    /// - Parameter agent: The user agent string to apply.
    @inlinable public init(_ agent: String) {
        self.agent = agent
    }
}

/// A `Content-Disposition` HTTP header.
///
/// Used to control content delivery, often for file uploads or downloads.
@frozen public struct ContentDisposition: RequestHeader, Equatable, Hashable, Sendable {
    /// The header value.
    public let value: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Content-Disposition": value]
    }
    
    /// Creates a `Content-Disposition` header with a custom value.
    ///
    /// - Parameter value: The header value to apply.
    @inlinable public init(_ value: String) {
        self.value = value
    }
    
    /// Creates a `Content-Disposition` header for form data.
    ///
    /// - Parameters:
    ///   - name: The name of the form field.
    ///   - fileName: The optional file name to associate with the field.
    public init(name: String, fileName: String? = nil) {
        var disposition = """
        form-data; name="\(name)"
        """
        if let fileName {
            disposition += """
            ; filename="\(fileName)"
            """
        }
        self.init(disposition)
    }
}

/// An `Authorization` HTTP header.
///
/// Use this header to apply authentication credentials to requests, such as bearer tokens or
/// basic authentication.
@frozen public struct Authorization: RequestHeader, Equatable, Hashable, Sendable {
    /// The raw value to use for the `Authorization` header.
    public var value: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Authorization": value]
    }
    
    /// Creates an `Authorization` header from a raw value.
    ///
    /// Use this when you already have a formatted string such as `"Bearer abc123"` or
    /// a custom scheme.
    ///
    /// - Parameter value: The full authorization header value.
    @inlinable public init(_ value: String) {
        self.value = value
    }
    
    /// Creates an `Authorization` header using a bearer token.
    ///
    /// The value will be formatted as `"Bearer <token>"`.
    ///
    /// - Parameter token: The bearer token to apply.
    @inlinable public init(bearer token: String) {
        self.init("Bearer \(token)")
    }
    
    /// Creates an `Authorization` header using HTTP Basic authentication.
    ///
    /// Combines the username and password into a base64-encoded string and formats
    /// the value as `"Basic <base64(username:password)>"`.
    ///
    /// - Parameters:
    ///   - username: The username to include.
    ///   - password: The password to include.
    public init(username: String, password: String) {
        let base64 = "\(username):\(password)"
            .data(using: .utf8)!
            .base64EncodedString()
        self.init("Basic \(base64)")
    }
}
