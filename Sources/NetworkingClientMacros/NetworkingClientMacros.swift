//
//  NetworkingClientMacros.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin for providing Networking macros.
@main
internal struct NetworkingClientMacros: CompilerPlugin {
    /// The macros provided by this plugin.
    internal let providingMacros: [any Macro.Type] = [
        ClientMacro.self,
        ClientInitMacro.self
    ]
}
