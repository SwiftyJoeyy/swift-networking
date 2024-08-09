//
//  RequestMacro.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

@attached(extension, conformances: Request)
@attached(member, conformances: Request, names: named(modifiers), arbitrary)
public macro Request() = #externalMacro(module: "NetworkKitMacros", type: "RequestMacro")
