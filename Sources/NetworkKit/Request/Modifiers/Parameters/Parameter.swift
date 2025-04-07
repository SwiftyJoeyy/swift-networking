//
//  Parameter.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A group of query parameters.
public typealias ParametersGroup = Parameter.Group

/// A query parameter.
///
/// You can use the ``Parameter`` macro to define and add
/// query parameters to a request in a concise and
/// readable manner, ensuring proper request configuration.
///
/// ```
/// @Request
/// struct GoogleRequest {
///     @Parameter("device") var device: String // Automatically applied.
///     @Parameter var language = "en"
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
@frozen public struct Parameter: RequestParameter {
    /// The key of the parameter.
    public var key: String
    
    /// The values associated with the key.
    public var value: [String?]
    
    /// The ``URLQueryItem`` parameters.
    public var parameters: [URLQueryItem] {
        return value.map({URLQueryItem(name: key, value: $0)})
    }
    
    /// Creates a new ``Parameter`` with a key and multiple values.
    ///
    /// - Parameters:
    ///  - key: The query parameter key.
    ///  - value: The values associated with the key.
    public init(_ key: String, value: [String?]) {
        self.key = key
        self.value = value
    }
    
    /// Creates a new ``Parameter`` with a key and a single optional value.
    ///
    /// - Parameters:
    ///  - key: The query parameter key.
    ///  - value: A single optional value associated with the key.
    @inlinable public init(_ key: String, value: String?) {
        self.init(key, value: [value])
    }
}

extension Parameter {
    /// A group of query parameters.
    @frozen public struct Group: RequestParameter {
        /// The query parameters contained in this group.
        public var parameters: [URLQueryItem]
        
        /// Creates a new ``ParametersGroup`` from an array of ``URLQueryItem``.
        ///
        /// - Parameter parameters: The query parameters.
        public init(_ parameters: [URLQueryItem]) {
            self.parameters = parameters
        }
        
        /// Creates a new ``Group`` from an array of optional ``URLQueryItem``.
        ///
        /// - Parameter parameters: The query parameters, with optional values.
        public init(_ parameters: [URLQueryItem?]) {
            self.init(parameters.compactMap(\.self))
        }
        
        /// Creates a new ``Group`` from an array of ``RequestParameter``.
        ///
        /// - Parameter parameters: The request parameters to be grouped.
        public init(_ parameters: [any RequestParameter]) {
            self.init(parameters.flatMap(\.parameters))
        }
        
        /// Creates a new ``Group`` using a builder closure for query parameters.
        ///
        /// - Parameter parameters: A builder closure returning a `ParametersGroup`.
        public init(@ParametersBuilder _ parameters: () -> ParametersGroup) {
            self = parameters()
        }
    }
}
