//
//  ClientMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit

internal enum ClientMacro {
// MARK: - Properties
    private static let sessionRequirement = "session"
    private static let sessionProperty = "_session"
    
// MARK: - Functions
    private static func checkSessionProperty(
        declaration: VariableDeclSyntax,
        propertyName: String,
        context: some MacroExpansionContext
    ) throws {
        guard propertyName == sessionProperty else {return}
        let node = Syntax(declaration)
        let diag = ClientMacroDiagnostic.unexpectedSessionDeclaration
            .diagnose(at: node)
            .fixIt { diag in
                FixIt(
                    message: MacroFixItMessage(
                        message: "Remove the '\(sessionProperty)' property declaration",
                        fixItID: diag.diagnosticID
                    ),
                    changes: [
                        .replace(oldNode: node, newNode: Syntax(TokenSyntax("")))
                    ]
                )
            }
        
        throw diag.error
    }
    private static func validate(
        declaration: some DeclGroupSyntax,
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
            
            try checkSessionProperty(
                declaration: varDecl,
                propertyName: propertyName,
                context: context
            )
            
            if !hasSessionRequirement {
                hasSessionRequirement = propertyName == sessionRequirement
            }
        }
        guard hasSessionRequirement else {
            throw ClientMacroDiagnostic.missingSessionDeclaration
        }
        return hasInitializer
    }
}

// MARK: - MemberMacro
extension ClientMacro: MemberMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let hasInitializer = try validate(
            declaration: declaration,
            in: context
        )
        var declarations = [
            DeclarationsFactory.makeSessionDecl(declaration.modifiers)
        ]
        
        if !hasInitializer {
            declarations.append(
                DeclarationsFactory.makeInitDecl(declaration.modifiers)
            )
        }
        
        return declarations
    }
}

// MARK: - ExtensionMacro
extension ClientMacro: ExtensionMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        return [
            DeclarationsFactory.makeExtensionDecl(type)
        ]
    }
}

// MARK: - MemberAttributeMacro
extension ClientMacro: MemberAttributeMacro {
    internal static func expansion(
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
