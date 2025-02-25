//
//  ModifierMacros.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit
import Foundation

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
