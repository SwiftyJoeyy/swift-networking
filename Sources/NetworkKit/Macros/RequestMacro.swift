//
//  RequestMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

@attached(extension, conformances: Request)
@attached(member, conformances: Request, names: named(_modifiers), named(id))
public macro Request(_ id: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "RequestMacro"
)
