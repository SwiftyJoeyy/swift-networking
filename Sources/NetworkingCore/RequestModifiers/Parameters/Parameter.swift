//
//  Parameter.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

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
@frozen public struct Parameter: RequestParameter, Equatable, Hashable, Sendable {
    /// The key of the parameter.
    public var name: String
    
    /// The values associated with the key.
    public var values: [String?]
    
    /// The ``URLQueryItem`` parameters.
    public var parameters: [URLQueryItem] {
        return values.map({URLQueryItem(name: name, value: $0)})
    }
    
    /// Creates a new ``Parameter`` with a name and multiple values.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its values.
    @inlinable public init(_ name: String, values: [String?]) {
        self.name = name
        self.values = values
    }
    
    /// Creates a new ``Parameter`` with a name and a single optional value.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    @inlinable public init(_ name: String, value: String?) {
        self.init(name, values: [value])
    }
}

/// A group of query parameters.
@frozen public struct ParametersGroup: RequestParameter, Equatable, Hashable, Sendable {
    /// The query parameters contained in this group.
    public var parameters: [URLQueryItem]
    
    /// Creates a new ``ParametersGroup`` from an array of ``URLQueryItem``.
    ///
    /// - Parameter parameters: The query parameters.
    @inlinable public init(_ parameters: [URLQueryItem]) {
        self.parameters = parameters
    }
    
    /// Creates a new ``ParametersGroup`` from an array of optional ``URLQueryItem``.
    ///
    /// - Parameter parameters: The query parameters, with optional values.
    @inlinable public init(_ parameters: [URLQueryItem?]) {
        self.init(parameters.compactMap(\.self))
    }
    
    /// Creates a new ``ParametersGroup`` using ``ParametersBuilder``.
    ///
    /// - Parameter parameter: A builder returning headers.
    @inlinable public init(
        @ParametersBuilder parameter: () -> some RequestParameter
    ) {
        self.init(parameter().parameters)
    }
}

// MARK: - Modifier
extension Request {
    /// Appends an additional query parameter with a single value to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .appendingParameter("language", value: "en")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    ///
    /// - Returns: A request with the additional query parameters applied.
    @inlinable public func appendingParameter(
        _ name: String,
        value: String?
    ) -> some Request {
        appendingParameter(Parameter(name, value: value))
    }
    
    /// Appends an additional query parameter with an array value to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .appendingParameter("language", value: "en")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - values: Its values.
    ///
    /// - Returns: A request with the additional query parameters applied.
    @inlinable public func appendingParameter(
        _ name: String,
        values: [String?]?
    ) -> some Request {
        appendingParameters {
            if let values {
                Parameter(name, values: values)
            }
        }
    }
}
