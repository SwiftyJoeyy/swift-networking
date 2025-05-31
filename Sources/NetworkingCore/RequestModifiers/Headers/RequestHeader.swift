//
//  RequestHeader.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Requirements for defining a request header modifier that adds custom
/// headers to a ``URLRequest``.
public protocol RequestHeader: RequestModifier, CustomStringConvertible {
    /// The HTTP headers to be added to the request.
    var headers: [String: String] {get}
}

// MARK: - RequestModifier
extension RequestHeader {
    /// Modifies the given ``URLRequest`` by appending custom headers.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest`` with headers added.
    public func modifying(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        return request
    }
}

// MARK: - CustomStringConvertible
extension RequestHeader {
    public var description: String {
        guard !headers.isEmpty else {
            return "\(String(describing: Self.self)) = []"
        }
        let headersString = headers
            .map({"  \($0) : \($1)"})
            .joined(separator: ",\n")
        
        return """
        \(String(describing: Self.self)) (\(headers.count)) = [
        \(headersString)
        ]
        """
    }
}

// MARK: - Modifier
extension Request {
    /// Adds additional headers to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .additionalHeaders {
    ///                 Header("language", value: "en")
    ///             }
    ///     }
    /// }
    /// ```
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
    ///
    /// - Parameter headers: A builder closure returning header parameters.
    /// - Returns: A request with the additional headers applied.
    @inlinable public func additionalHeaders(
        @HeadersBuilder _ headers: () -> some RequestHeader
    ) -> some Request {
        modifier(headers())
    }
}
