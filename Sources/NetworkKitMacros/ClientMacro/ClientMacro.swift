//
//  ClientMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit
import Foundation

package enum ClientMacro {
    private static let commandRequirement = "command"
    private static let commandProperty = "_command"
    
    private static func checkCommandProperty(
        declaration: VariableDeclSyntax,
        propertyName: String,
        context: some MacroExpansionContext
    ) {
        guard propertyName == commandProperty else {return}
        let node = Syntax(declaration)
        let message = MacroErrorFixItMessage(
            message: "Remove the '_command' property declaration",
            id: "unexpectedCommandDeclaration"
        )
        let fixIt = FixIt(
            message: message,
            changes: [
                .replace(oldNode: node, newNode: Syntax(TokenSyntax("")))
            ]
        )
        let error = ClientMacroError.unexpectedCommandDeclaration
        let diagnostic = Diagnostic(node: node, message: error, fixIt: fixIt)
        context.diagnose(diagnostic)
    }
    
    @discardableResult
    private static func validateClient(
        declaration: some DeclGroupSyntax,
        checkCommand: Bool,
        in context: some MacroExpansionContext
    ) throws -> Bool {
        var hasInitializer = false
        var hasCommandRequirement = false
        
        for member in declaration.memberBlock.members {
            guard !member.decl.is(InitializerDeclSyntax.self) else {
                hasInitializer = true
                continue
            }
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let propertyName = varDecl.name?.text
            else {continue}
            if checkCommand {
                checkCommandProperty(
                    declaration: varDecl,
                    propertyName: propertyName,
                    context: context
                )
            }
            if !hasCommandRequirement {
                hasCommandRequirement = propertyName == commandRequirement
            }
        }
        guard hasCommandRequirement else {
            throw ClientMacroError.missingCommandDeclaration
        }
        return hasInitializer
    }
}

// MARK: - MemberMacro
extension ClientMacro: MemberMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try withErroHandling(context: context, node: node, onFailure: []) {
            let hasInitializer = try validateClient(
                declaration: declaration,
                checkCommand: true,
                in: context
            )
            let accessLevel = declaration.modifiers.accessLevel?.modifier
            let commandDecl = DeclarationsFactory.makeCommandDecl(accessLevel)
            var declarations = [commandDecl]
            
            if !hasInitializer {
                let initDecl = DeclarationsFactory.makeInitDecl(accessLevel)
                declarations.append(initDecl)
            }
            
            return declarations
        }
    }
}

// MARK: - ExtensionMacro
extension ClientMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        do {
            try validateClient(
                declaration: declaration,
                checkCommand: false,
                in: context
            )
            return [
                DeclarationsFactory.makeExtensionDecl(type)
            ]
        }catch {
            return []
        }
    }
}

// MARK: - MemberAttributeMacro
extension ClientMacro: MemberAttributeMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard member.is(InitializerDeclSyntax.self) else {
            return []
        }
        return [
            DeclarationsFactory.makeInitAttribute()
        ]
    }
}
