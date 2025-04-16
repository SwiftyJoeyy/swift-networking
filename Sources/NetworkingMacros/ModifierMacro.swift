//
//  ModifierMacros.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

package protocol ModifierMacro: PeerMacro { }

// MARK: - PeerMacro
extension ModifierMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

package enum HeaderMacro: ModifierMacro { }

package enum ParameterMacro: ModifierMacro { }
