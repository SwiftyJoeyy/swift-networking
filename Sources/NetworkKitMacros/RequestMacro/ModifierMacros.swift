//
//  ModifierMacros.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

package protocol ModifierMacro: PeerMacro {
    static func modifier(key: TokenSyntax, value: TokenSyntax) -> TokenSyntax
}

//MARK: - PeerMacro
extension ModifierMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try withErroHandling(context: context, node: node, onFailure: []) {
            guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
                  let propertyName = variableDeclaration.name?.trimmed else {
                throw RequestMacroError.invalidDeclaration
            }
            let attribute = variableDeclaration.attributes.first?.argumentName
            let key = (attribute ?? propertyName).trimmed
            
            return [
            """
            private var __\(propertyName): RequestModifier {
                return \(modifier(key: key, value: propertyName))
            }
            """
            ]
        }
    }
}

package enum HeaderMacro: ModifierMacro {
    package static func modifier(key: TokenSyntax, value: TokenSyntax) -> TokenSyntax {
        return """
        Header("\(key)", value: \(value))
        """
    }
}

package enum ParameterMacro: ModifierMacro {
    package static func modifier(key: TokenSyntax, value: TokenSyntax) -> TokenSyntax {
        return """
        Parameter("\(key)", value: \(value))
        """
    }
}
