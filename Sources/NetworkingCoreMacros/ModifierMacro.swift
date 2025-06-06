//
//  ModifierMacros.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

internal protocol ModifierMacro: PeerMacro { }

// MARK: - PeerMacro
extension ModifierMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

internal enum HeaderMacro: ModifierMacro { }

internal enum ParameterMacro: ModifierMacro { }
