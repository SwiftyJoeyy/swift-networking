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
    /// The configuration values available to this instance.
    @Configurations private var configurations
    
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
            request._accept(configurations)
            return try request._makeURLRequest()
        }
    }
    
// MARK: - Functions
    /// Constructs a ``URLRequest`` from this request.
    ///
    /// This method builds the final ``URLRequest`` by resolving the base URL, appending the path,
    /// and applying all configured modifiers.
    ///
    /// - Returns: The configured ``URLRequest``.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _makeURLRequest() throws -> URLRequest {
        return try requestBuilder(configurations)
    }
    
    /// Applies new configuration values to the erased request.
    ///
    /// This method is called internally to inject values during evaluation. You typically
    /// do not call this method directly.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        _configurations._accept(values)
    }
}
