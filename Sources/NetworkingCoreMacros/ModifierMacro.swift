//
//  ModifierMacros.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import MacrosKit
import SwiftDiagnostics

internal protocol ModifierMacro: PeerMacro {
    /// The name of the macro.
    static var name: String {get}
}

// MARK: - PeerMacro
extension ModifierMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let diag = ModifierMacroDiagnostic(macroName: name)
            .diagnose(at: node)
        
        guard declaration.is(VariableDeclSyntax.self) else {
            throw diag.error
        }
        let parentDecl = context.lexicalContext.first
        let declSyntax = parentDecl?.asProtocol((any DeclSyntaxProtocol).self)
        let hasRequestMacro = (declSyntax?.declaration?.attributes ?? [])
            .contains { attribute in
                let type = attribute.attribute?.attributeName
                let name = type?.as(IdentifierTypeSyntax.self)?.name.text
                return name == "Request"
            }
        guard !hasRequestMacro else {
            return []
        }
        
        throw diag.error
    }
}

internal enum HeaderMacro: ModifierMacro {
    /// The name of the macro.
    internal static let name = "Header"
}

internal enum ParameterMacro: ModifierMacro {
    /// The name of the macro.
    internal static let name = "Parameter"
}


internal struct ModifierMacroDiagnostic: DiagnosticMessage {
    /// The name of the macro.
    internal let macroName: String
    
    /// The diagnostic messages.
    internal var message: String {
        return "'@\(macroName)' macro can only attach to properties inside a type marked with the '@Request' macro"
    }
    
    /// The severity level of the diagnostic message.
    internal let severity = DiagnosticSeverity.error
    
    /// The unique identifier for the diagnostic message.
    internal var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros", id: macroName)
    }
}
