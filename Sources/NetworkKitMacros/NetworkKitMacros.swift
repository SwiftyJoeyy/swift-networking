//
//  NetworkKitMacros.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// Compiler plugin for providing NetworkKit macros.
@main
struct NetworkKitMacros: CompilerPlugin {
    /// The macros provided by this plugin.
    let providingMacros: [Macro.Type] = [
        ClientMacro.self,
        ClientInitMacro.self,
        RequestMacro.self,
        HeaderMacro.self,
        ParameterMacro.self
    ]
}
