//
//  ModifierMacros.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

/// Macro for defining an HTTP header field in a request.
///
/// This macro allows you to declare an HTTP header as part of a request structure,
/// improving readability and maintainability.
///
/// - You can specify a custom key or use the property's name as the key.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Header("device") var device = "iPhone"
///     // or
///     @Header var device = "iPhone"
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - You can leave the property uninitialized and assign a value during initialization.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Header("device") var device: String
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - You can make the property optional so the header is only applied when it has a value.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Header("device") var device: String?
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - Parameter key: The key of the HTTP header.
/// If not provided, it will be inferred from the propery name.
///
/// - Warning: For this macro to work your request must use the ``Request`` macro.
@attached(peer)
public macro Header(_ key: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "HeaderMacro"
)

/// Macro for defining a query parameter in a request.
///
/// This macro allows you to declare a query parameter as part of a request structure,
/// improving readability and maintainability.
///
/// - You can specify a custom key or use the property's name as the key.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Parameter("device") var device = "iPhone"
///     // or
///     @Parameter var device = "iPhone"
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - You can leave the property uninitialized and assign a value during initialization.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Parameter("device") var device: String
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - You can make the property optional so the parameter is only applied when it has a value.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Parameter("device") var device: String?
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - You can use arrays and arrays of optionals so that a parameter
///  can hold multiple values that are applied when available.
/// ```
/// @Request
/// struct GoogleRequest {
///     @Parameter var devices = ["iPhone", "iPad"]
///     // or
///     @Parameter var devices: [String?]
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - Parameter key: The key of the parameter.
/// If not provided, it will be inferred from the propery name.
///
/// - Warning: For this macro to work your request must use the ``Request`` macro.
@attached(peer)
public macro Parameter(_ key: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "ParameterMacro"
)
