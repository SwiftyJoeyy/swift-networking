//
//  RequestMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

package enum RequestMacro {
    private static let requestRequirement = "request"
    
    private static func validateRequest(
        declaration: some DeclGroupSyntax,
        map: ((_ varDecl: VariableDeclSyntax, _ name: TokenSyntax) -> Void)? = nil
    ) throws {
        var hasRequestRequirement = false
        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let name = varDecl.name
            else {continue}
            
            if !hasRequestRequirement {
                hasRequestRequirement = name.text == requestRequirement
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
                    let argument = attribute.attribute?.arguments?.unnamed.first
                    return RequestMacroModifier(
                        type: type,
                        name: (argument ?? varName).trimmed,
                        value: varName.trimmed,
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
        let modifiers = try getModifiers(declaration: declaration)
        let requestID = node.arguments?.unnamed.first
        
        var declarations = [
            DeclarationsFactory.makeModifiersDecl(
                modifiers: declaration.modifiers,
                reqModifiers: modifiers
            )
        ]
        if !modifiers.isEmpty {
            declarations.append(
                DeclarationsFactory.makeModifiersBoxDecl(
                    modifiers: [DeclModifierSyntax(name: .keyword(.private))],
                    "_modifiersBox"
                )
            )
        }
        let hasIDProperty = declaration.memberBlock.members
            .contains { member in
                let varDecl = member.decl.as(VariableDeclSyntax.self)
                return varDecl?.name?.text == "id"
            }
        
        if !hasIDProperty, let id = requestID ?? declaration.typeName {
            declarations.append(
                DeclarationsFactory.makeIDDecl(
                    modifiers: declaration.modifiers,
                    id: id.text
                )
            )
        }
        return declarations
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
