//
//  RequestBody.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Requirements for defining a request body modifier that sets the HTTP body
/// and its associated content type.
public protocol RequestBody: RequestModifier {
    /// The content type of the request body.
    var contentType: ContentType? {get}
    
    /// Encodes and returns the request body as ``Data``.
    ///
    /// - Returns: The encoded body data.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    func body() throws(NetworkingError) -> Data?
}

// MARK: - RequestModifier
extension RequestBody {
    /// Modifies the given ``URLRequest`` by setting its content type and body.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest`` with the body set.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    public func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        let body = try body()
        guard let body else {
            return request
        }
        
        if let contentType {
            request = try contentType.modifying(consume request)
        }
        request.httpBody = body
        return request
    }
}

// MARK: - Modifier
extension Request {
    /// Sets the request body using a request body modifier.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .body {
    ///                 JSON([
    ///                     "date": "1/16/2025"
    ///                 ])
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter body: The request body.
    /// - Returns: A request with the specified body applied.
    @inlinable public func body(
        _ body: () -> some RequestBody
    ) -> some Request {
        modifier(body())
    }
}
