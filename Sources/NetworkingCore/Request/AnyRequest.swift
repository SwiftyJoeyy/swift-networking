//
//  AnyRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 27/04/2025.
//

import Foundation

/// A type-erased request.
@frozen public struct AnyRequest: Request {
    /// The contents of the request.
    public typealias Contents = Never
    
// MARK: - Properties
    /// The request's identifier.
    public let id: String
    
    /// The request builder used to type erase a request.
    private let requestBuilder: (
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest
    
// MARK: - Initializer
    /// Create an instance that type-erases `request`.
    public init(_ request: some Request) {
        self.id = request.id
        self.requestBuilder = { configurations in
            try request._makeURLRequest(configurations)
        }
    }
    
// MARK: - Functions
    /// Constructs a ``URLRequest`` from this ``HTTPRequest``
    /// and the provided configuration context.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Parameter configurations: The context in which to evaluate the request, including
    ///   fallback values like ``ConfigurationValues/baseURL``.
    /// - Returns: The configured ``URLRequest``.
    public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        return try requestBuilder(configurations)
    }
}
