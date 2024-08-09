//
//  ModifierMacros.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

@attached(peer, names: prefixed(__))
public macro Header(_ key: String = "") = #externalMacro(module: "NetworkKitMacros", type: "HeaderMacro")

@attached(peer, names: prefixed(__))
public macro Parameter(_ key: String = "") = #externalMacro(module: "NetworkKitMacros", type: "ParameterMacro")
