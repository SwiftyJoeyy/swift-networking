//
//  AnyRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 27/04/2025.
//

import Foundation

/// A type-erased request.
@frozen public struct AnyRequest: Request, Sendable {
    /// The contents of the request.
    public typealias Contents = Never
    
// MARK: - Properties
    /// The request builder used to type erase a request.
    private let storage: AnyRequestStorageBase
    
    /// The request's identifier.
    public var id: String {
        return storage.id
    }
    
    /// Accessing this property will always result in a fatal error.
    ///
    /// - Warning: This should not be accessed directly.
    public var request: Never {
        fatalError("Should not be called directly!!")
    }
    
    public var description: String {
        return """
        \(String(describing: Self.self)) {
          id = \(id)
        }
        """
    }
    
// MARK: - Initializer
    /// Create an instance that type-erases `request`.
    public init(_ request: some Request) {
        self.storage = AnyRequestStorage(request: request)
    }
    
// MARK: - Functions
    /// Constructs a ``URLRequest`` from this request, using the provided configurations.
    ///
    /// This method is responsible for producing the final ``URLRequest`` that will be
    /// sent over the network. It ensures that all relevant configurations and
    /// modifiers are applied.
    ///
    /// - Parameter configurations: The resolved ``ConfigurationValues`` to use during construction.
    /// - Returns: A fully configured ``URLRequest``.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws(NetworkingError) -> URLRequest {
        return try storage.makeURLRequest(with: configurations)
    }
    
    /// Applies new configuration values to the erased request.
    ///
    /// This method is called internally to inject values during evaluation. You typically
    /// do not call this method directly.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        storage.accept(values)
    }
}

extension AnyRequest {
    /// An abstract base class for type-erased request storage.
    @usableFromInline internal class AnyRequestStorageBase: @unchecked Sendable {
        /// The request's identifier.
        internal var id: String {
            fatalError("Subclasses must override this member.")
        }
        
        /// Creates a ``URLRequest`` from the underlying request.
        ///
        /// - Returns: A configured ``URLRequest``.
        /// - Throws: A ``NetworkingError`` if request construction fails.
        internal func makeURLRequest(
            with configurations: ConfigurationValues
        ) throws(NetworkingError) -> URLRequest {
            fatalError("Subclasses must override this member.")
        }
        
        /// Applies the specified configuration values to the underlying request.
        ///
        /// - Parameter values: The configuration values to apply.
        internal func accept(_ values: ConfigurationValues) {
            fatalError("Subclasses must override this member.")
        }
    }
    
    /// A concrete storage type for a specific ``Request`` instance.
    fileprivate final class AnyRequestStorage<R: Request>: AnyRequestStorageBase, @unchecked Sendable {
        /// The wrapped request.
        private let request: R
        
        /// The request's identifier.
        fileprivate override var id: String {
            return request.id
        }
        
        /// Creates a new instance that wraps the given request.
        ///
        /// - Parameter request: The request to wrap.
        fileprivate init(request: R) {
            self.request = request
        }
        
        /// Builds a ``URLRequest`` from the wrapped request.
        ///
        /// - Returns: A configured ``URLRequest``.
        /// - Throws: A ``NetworkingError`` if request construction fails.
        fileprivate override func makeURLRequest(
            with configurations: ConfigurationValues
        ) throws(NetworkingError) -> URLRequest {
            return try request._makeURLRequest(with: configurations)
        }
        
        /// Applies the specified configuration values to the wrapped request.
        ///
        /// - Parameter values: The configuration values to apply.
        fileprivate override func accept(_ values: ConfigurationValues) {
            request._accept(values)
        }
    }
}
