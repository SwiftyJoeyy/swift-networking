//
//  ModifierMacros.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

@attached(peer)
public macro Header(_ key: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "HeaderMacro"
)

@attached(peer)
public macro Parameter(_ key: String = "") = #externalMacro(
    module: "NetworkKitMacros",
    type: "ParameterMacro"
)
