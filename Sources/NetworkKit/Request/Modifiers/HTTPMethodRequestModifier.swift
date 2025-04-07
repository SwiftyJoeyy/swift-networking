//
//  HTTPMethodRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Request modifier for setting the HTTP method of a ``URLRequest``.
///
/// - Note: Use ``Request/method(_:)`` instead of directly using this.
@usableFromInline internal struct HTTPMethodRequestModifier {
    /// The HTTP method to apply to the request.
    private let httpMethod: RequestMethod
    
    /// Creates a new ``HTTPMethodRequestModifier`` with the specified HTTP method.
    ///
    /// - Parameter httpMethod: The HTTP method to apply.
    @usableFromInline internal init(_ httpMethod: RequestMethod) {
        self.httpMethod = httpMethod
    }
}

// MARK: - RequestModifier
extension HTTPMethodRequestModifier: RequestModifier {
    /// Modifies the given ``URLRequest`` by setting its HTTP method.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest``.
    @usableFromInline internal func modifying(
        _ request: consuming URLRequest,
        with configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        request.httpMethod = httpMethod.rawValue
        return request
    }
}

// MARK: - Modifier
extension Request {
    /// Applies an HTTP method modifier to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .method(.get)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter httpMethod: The HTTP method to set.
    /// - Returns: A request with the specified HTTP method applied.
    @inlinable public consuming func method(
        _ httpMethod: RequestMethod
    ) -> some Request {
        modifier(HTTPMethodRequestModifier(httpMethod))
    }
}
