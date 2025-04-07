//
//  RequestMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

/// Macro for defining a request structure that conforms to ``Request``.
///
/// This macro simplifies the process of defining a request by automatically
/// adding necessary properties and conformances.
/// It automatically adds the requirements needed to conform to ``Request``.
///
/// ```
/// @Request
/// struct FetchUserRequest {
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// You can specify a custom request ID or use the default value.
///
/// ```
/// @Request("fetchUser")
/// struct FetchUserRequest {
///     var request: some Request {
///         // ...
///     }
/// }
/// ```
///
/// - Parameter id: A unique identifier for the request. Defaults to an empty string.
///
/// - Note: This macros is needed for the ``Header`` & ``Parameter``
/// macros to work.
@attached(extension, conformances: Request)
@attached(member, conformances: Request, names: named(_modifiers), named(id), named(_modifiersBox))
public macro Request(_ id: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "RequestMacro"
)
