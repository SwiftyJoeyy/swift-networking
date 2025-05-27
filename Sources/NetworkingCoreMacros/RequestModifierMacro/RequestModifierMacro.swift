//
//  RequestModifierMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 25/05/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros

package enum RequestModifierMacro { }

// MARK: - MemberMacro
extension RequestModifierMacro: MemberMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = DynamicConfigDeclFactory.make(for: declaration) else {
            return []
        }
        return [DeclSyntax(funcDecl)]
    }
}

// MARK: - ExtensionMacro
extension RequestModifierMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let inheritedType = InheritedTypeSyntax(
            type: IdentifierTypeSyntax(name: "RequestModifier")
        )
        let decl = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [inheritedType]
            )
        ) { }
        return [decl]
    }
}
