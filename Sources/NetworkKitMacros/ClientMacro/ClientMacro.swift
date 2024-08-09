//
//  ClientMacro.swift
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

package enum ClientMacro {
    private static let commandRequirement = "command"
    
    private static func checkCommandProperty(declaration: some DeclGroupSyntax) throws {
        let memberDeclarations = declaration.memberBlock.members.contains { member in
            let variableDeclaration = member.decl.as(VariableDeclSyntax.self)
            let name = variableDeclaration?.name?.trimmed.text
            return name == commandRequirement
        }
        guard !memberDeclarations else {return}
        
        throw ClientMacroError.missingCommandDeclaration
    }
}

//MARK: - MemberMacro
extension ClientMacro: MemberMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try withErroHandling(context: context, node: node, onFailure: []) {
            let accessLevel = declaration.modifiers.accessLevel?.modifier ?? ""
            try checkCommandProperty(declaration: declaration)
            let aggregatedCommandDeclaration: DeclSyntax =
            """
            \(accessLevel)var aggregatedCommand: ClientCommand!
            """
            
            let initDeclaration: DeclSyntax =
            """
            \(accessLevel)init() {
                self.aggregatedCommand = command
            }
            """
            return [
                aggregatedCommandDeclaration,
                initDeclaration
            ]
        }
    }
}

//MARK: - ExtensionMacro
extension ClientMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        do {
            try checkCommandProperty(declaration: declaration)
            
            let protocolExtension: DeclSyntax =
            """
            extension \(type.trimmed): NetworkingClient { }
            """
            guard let declaration = protocolExtension.as(ExtensionDeclSyntax.self) else {
                return []
            }
            return [declaration]
        }catch {
            return []
        }
    }
}

//MARK: - MemberAttributeMacro
extension ClientMacro: MemberAttributeMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        let variableDeclaration = member.as(VariableDeclSyntax.self)
        let binding = variableDeclaration?.bindings.first
        let declarationName = binding?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        let commandVariable = declarationName == commandRequirement
        
        guard commandVariable else {
            return []
        }
        return [
            "@ClientCommandBuilder"
        ]
    }
}
