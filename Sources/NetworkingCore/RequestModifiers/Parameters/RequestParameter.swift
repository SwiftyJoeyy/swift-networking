//
//  RequestParameter.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Requirements for defining a request parameter modifier that adds
/// query parameters to a ``URLRequest``.
public protocol RequestParameter: RequestModifier, CustomStringConvertible {
    /// The query parameters to be added to the request.
    var parameters: [URLQueryItem] {get}
}

// TODO: - Add support for parameter encoding strategies (ie: arrays)

// MARK: - RequestModifier
extension RequestParameter {
    /// Modifies the given ``URLRequest`` by appending query parameters.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest`` with query parameters added.
    public func modifying(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *) {
            request.url?.append(queryItems: parameters)
            return request
        }
        guard let url = request.url else {
            return request
        }
        var components = URLComponents(string: url.absoluteString)
        let queryItems = components?.queryItems ?? []
        components?.queryItems = queryItems + parameters
        request.url = components?.url
        return request
    }
}


// MARK: - CustomStringConvertible
extension RequestParameter {
    public var description: String {
        guard !parameters.isEmpty else {
            return "\(String(describing: Self.self)) = []"
        }
        let paramsString = parameters
            .map({"  \($0.name) : \($0.value ?? "nil")"})
            .joined(separator: ",\n")
        return """
        \(String(describing: Self.self)) (\(parameters.count)) = [
        \(paramsString)
        ]
        """
    }
}

// MARK: - Modifier
extension Request {
    /// Appends additional query parameters to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .appendingParameters {
    ///                 Parameter("language", value: "en")
    ///                 Parameter("platforms", values: ["iOS", "iPadOS"])
    ///             }
    ///     }
    /// }
    /// ```
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
    ///
    /// - Parameter parameters: A builder closure returning query parameters.
    /// - Returns: A request with the additional query parameters applied.
    @inlinable public func appendingParameters(
        @ParametersBuilder _ parameters: () -> some RequestParameter
    ) -> some Request {
        modifier(parameters())
    }
    
    /// Appends an additional query parameter to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .appendingParameter(Parameter("language", value: "en"))
    ///     }
    /// }
    /// ```
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
    ///
    /// - Parameter parameter: A query parameter.
    /// - Returns: A request with the additional query parameters applied.
    @inlinable public func appendingParameter(
        _ parameter: some RequestParameter
    ) -> some Request {
        modifier(parameter)
    }
}
