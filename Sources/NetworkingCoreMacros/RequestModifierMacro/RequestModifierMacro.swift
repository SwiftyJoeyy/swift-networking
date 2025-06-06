//
//  RequestModifierMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 25/05/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

internal enum RequestModifierMacro { }

// MARK: - MemberMacro
extension RequestModifierMacro: MemberMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
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
    internal static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
//        let conformsToRequest = declaration.memberBlock.members
//            .contains { member in
//                guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
//                    return false
//                }
//                return funcDecl.name.text == "modifying"
//            }
//        if !conformsToRequest {
//            let typeName = declaration.typeName?.text ?? ""
//            let diagnostic = Diagnostic(
//                node: node,
//                message: Message.invalidConformance(typeName: typeName)
//            )
//            context.diagnose(diagnostic)
//        }
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
