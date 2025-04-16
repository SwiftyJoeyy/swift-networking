//
//  ClientMacro.swift
//  Networking
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
    private static let sessionRequirement = "session"
    private static let sessionProperty = "_session"
    
    private static func checkSessionProperty(
        declaration: VariableDeclSyntax,
        propertyName: String,
        context: some MacroExpansionContext
    ) throws {
        guard propertyName == sessionProperty else {return}
        let node = Syntax(declaration)
        let message = MacroErrorFixItMessage(
            message: "Remove the '\(sessionProperty)' property declaration",
            id: "unexpectedSessionDeclaration"
        )
        let fixIt = FixIt(
            message: message,
            changes: [
                .replace(oldNode: node, newNode: Syntax(TokenSyntax("")))
            ]
        )
        let error = ClientMacroError.unexpectedSessionDeclaration
        let diagnostic = Diagnostic(node: node, message: error, fixIt: fixIt)
        context.diagnose(diagnostic)
        throw NSError(domain: "", code: 0)
    }
    
    @discardableResult
    private static func validateClient(
        declaration: some DeclGroupSyntax,
        checkSession: Bool,
        in context: some MacroExpansionContext
    ) throws -> Bool {
        var hasInitializer = false
        var hasSessionRequirement = false
        
        for member in declaration.memberBlock.members {
            guard !member.decl.is(InitializerDeclSyntax.self) else {
                hasInitializer = true
                continue
            }
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let propertyName = varDecl.name?.text
            else {continue}
            if checkSession {
                try checkSessionProperty(
                    declaration: varDecl,
                    propertyName: propertyName,
                    context: context
                )
            }
            if !hasSessionRequirement {
                hasSessionRequirement = propertyName == sessionRequirement
            }
        }
        guard hasSessionRequirement else {
            throw ClientMacroError.missingSessionDeclaration
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
                checkSession: true,
                in: context
            )
            let accessLevel = declaration.modifiers.accessLevel?.name
            let commandDecl = DeclarationsFactory.makeSessionDecl(accessLevel)
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
                checkSession: false,
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
