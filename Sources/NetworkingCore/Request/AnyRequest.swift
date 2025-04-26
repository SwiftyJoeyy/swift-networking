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
    
    /// The request modifiers applied to this request.
    public var _modifiers = [any RequestModifier]()
    
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
    /// Constructs a ``URLRequest`` using the given base url.
    ///
    /// - Parameter baseURL: The base URL to use if the request does not have one.
    /// - Returns: The configured ``URLRequest``.
    public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        return try requestBuilder(configurations)
    }
}
