//
//  ClientMacro.swift
//  Networking
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
/// @Client struct MyClient {
///     var session: Session {
///         Session {
///             URLSessionConfiguration.default
///                 .timeoutIntervalForRequest(60)
///                 .timeoutIntervalForResource(120)
///                 .requestCachePolicy(.useProtocolCachePolicy)
///         }.onRequest { request, task, session, configurations in
///             // handle request creation
///             return request
///         }.enableLogs()
///         .validate(for: [.accepted, .ok])
///         .doNotRetry()
///     }
/// }
/// ```
@attached(extension, conformances: NetworkClient)
@attached(member, conformances: NetworkClient, names: named(_session), named(init))
@attached(memberAttribute)
public macro Client() = #externalMacro(
    module: "NetworkingClientMacros",
    type: "ClientMacro"
)

@attached(body)
public macro ClientInit() = #externalMacro(
    module: "NetworkingClientMacros",
    type: "ClientInitMacro"
)
