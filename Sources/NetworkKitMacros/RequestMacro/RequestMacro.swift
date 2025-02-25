//
//  RequestMacro.swift
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

package enum RequestMacro {
    private static let requestRequirement = "request"
    
    private static func validateRequest(
        declaration: some DeclGroupSyntax,
        map: ((_ varDecl: VariableDeclSyntax, _ name: String) -> Void)? = nil
    ) throws {
        var hasRequestRequirement = false
        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let name = varDecl.name?.text
            else {continue}
            
            if !hasRequestRequirement {
                hasRequestRequirement = name == requestRequirement
            }
            map?(varDecl, name)
        }
        
        if !hasRequestRequirement {
            throw RequestMacroError.missingRequestDeclaration
        }
    }
    
    private static func getModifiers(
        declaration: some DeclGroupSyntax
    ) throws -> [RequestMacroModifier] {
        var modifiers = [RequestMacroModifier]()
        try validateRequest(declaration: declaration) { varDecl, varName in
            let isOptional = varDecl.bindings.first?
                .typeAnnotation?
                .type
                .is(OptionalTypeSyntax.self)
            let varModifiers = varDecl.attributes
                .compactMap { attribute -> RequestMacroModifier? in
                    guard let name = attribute.name?.text,
                          let type = RequestModifierType(rawValue: name)
                    else {
                        return nil
                    }
                    let argument = attribute.argumentName?.text
                    return RequestMacroModifier(
                        type: type,
                        name: argument ?? varName,
                        value: varName,
                        isOptional: isOptional ?? false
                    )
                }
            modifiers.append(contentsOf: varModifiers)
        }
        return modifiers
    }
}

// MARK: - MemberMacro
extension RequestMacro: MemberMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try withErroHandling(context: context, node: node, onFailure: []) {
            let modifiers = try getModifiers(declaration: declaration)
            let requestID = declaration.attributes.first?.argumentName?.text
            let accessLevel = declaration.modifiers.accessLevel?.name
            
            var declarations = [
                DeclarationsFactory.makeModifiersDecl(
                    accessLevel: accessLevel,
                    modifiers: modifiers
                )
            ]
            if let requestID {
                let idDecl = DeclarationsFactory.makeIDDecl(
                    accessLevel: accessLevel,
                    id: requestID
                )
                declarations.append(idDecl)
            }
            return declarations
        }
    }
}

// MARK: - ExtensionMacro
extension RequestMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        do {
            try validateRequest(declaration: declaration)
            return [DeclarationsFactory.makeExtensionDecl(type)]
        }catch {
            return []
        }
    }
}
