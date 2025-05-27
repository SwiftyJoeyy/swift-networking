//
//  NetworkingCoreMacros.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin for providing Networking macros.
@main
internal struct NetworkingCoreMacros: CompilerPlugin {
    /// The macros provided by this plugin.
    internal let providingMacros: [any Macro.Type] = [
        RequestMacro.self,
        HeaderMacro.self,
        ParameterMacro.self,
        ConfigurationKeyMacro.self,
        RequestModifierMacro.self
    ]
}
