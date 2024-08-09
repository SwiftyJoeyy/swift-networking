//
//  ClientMacro.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

@attached(memberAttribute)
@attached(extension, conformances: NetworkingClient)
@attached(member, conformances: NetworkingClient, names: named(aggregatedCommand), arbitrary)
public macro Client() = #externalMacro(module: "NetworkKitMacros", type: "ClientMacro")

