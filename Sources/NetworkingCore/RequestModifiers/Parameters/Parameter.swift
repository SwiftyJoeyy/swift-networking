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
    public var values: [String?]?
    
    /// The ``URLQueryItem`` parameters.
    public var parameters: [URLQueryItem] {
        guard let values else {
            return []
        }
        return values.compactMap { value in
            return value.map({URLQueryItem(name: name, value: $0)})
        }
    }
}

// MARK: - Array Initializers
extension Parameter {
    /// Creates a new ``Parameter`` with a name and multiple ``String`` values.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its values.
    @inlinable public init(_ name: String, values: [String?]?) {
        self.name = name
        self.values = values
    }
    
    /// Creates a new ``Parameter`` with a name and multiple ``Int`` values.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its values.
    public init(_ name: String, values: [Int?]?) {
        self.init(name, values: values?.map({$0?.description}))
    }
    
    /// Creates a new ``Parameter`` with a name and multiple ``Double`` values.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its values.
    public init(_ name: String, values: [Double?]?) {
        self.init(name, values: values?.map({$0?.description}))
    }
    
    /// Creates a new ``Parameter`` with a name and multiple ``Bool`` values.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its values.
    public init(_ name: String, values: [Bool?]?) {
        self.init(name, values: values?.map({$0?.description}))
    }
}

// MARK: - Initializers
extension Parameter {
    /// Creates a new ``Parameter`` with a name and a single optional ``String`` value.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    @inlinable public init(_ name: String, value: String?) {
        self.init(name, values: [value])
    }
    
    /// Creates a new ``Parameter`` with a name and a single optional ``Int`` value.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    public init(_ name: String, value: Int?) {
        self.init(name, value: value?.description)
    }
    
    /// Creates a new ``Parameter`` with a name and a single optional ``Double`` value.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    public init(_ name: String, value: Double?) {
        self.init(name, value: value?.description)
    }
    
    /// Creates a new ``Parameter`` with a name and a single optional ``Bool`` value.
    ///
    /// - Parameters:
    ///  - name: The query parameter's name.
    ///  - value: Its value.
    public init(_ name: String, value: Bool?) {
        self.init(name, value: value?.description)
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
        self.init(parameters.compactMap({$0}))
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
    ///             .appendingParameter("language", values: ["en"])
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
            Parameter(name, values: values)
        }
    }
}
