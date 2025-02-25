//
//  ClientMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/25/25.
//

import Foundation

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
