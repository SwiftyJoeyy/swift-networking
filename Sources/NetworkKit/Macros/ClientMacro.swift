//
//  ClientMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/25/25.
//

import Foundation

/// Macro for defining a network client that conforms to ``NetworkClient``.
///
/// This macro simplifies the creation of a network client by automatically
/// adding the necessary ``NetworkClient`` conformance.
///
/// ```
/// @Client
/// struct MyClient {
///     var command: Session {
///         Session()
///             .onRequest { request, session in
///                 // handle request creation
///                 return request
///             }.enableLogs()
///             .validate(for: [.accepted, .ok])
///             .retryPolicy(.doNotRetry)
///     }
/// }
/// ```
@attached(extension, conformances: NetworkClient)
@attached(member, conformances: NetworkClient, names: named(_command), named(init))
@attached(memberAttribute)
public macro Client() = #externalMacro(
    module: "NetworkKitMacros",
    type: "ClientMacro"
)

#if hasFeature(BodyMacros)
@attached(body)
public macro ClientInit() = #externalMacro(
    module: "NetworkKitMacros",
    type: "ClientInitMacro"
)
#endif
