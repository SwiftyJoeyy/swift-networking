//
//  NetworkKitMacros.swift
//
//
//  Created by Joe Maghzal on 5/23/24.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin for providing NetworkKit macros.
@main
struct NetworkKitMacros: CompilerPlugin {
    /// The macros provided by this plugin.
    let providingMacros: [Macro.Type] = [
        ClientMacro.self,
        RequestMacro.self,
        HeaderMacro.self,
        ParameterMacro.self
    ]
}
