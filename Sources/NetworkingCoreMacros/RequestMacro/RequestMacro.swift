//
//  RequestMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import MacrosKit

internal enum RequestMacro {
    private static func validateRequest(
        declaration: some DeclGroupSyntax
    ) throws {
        let hasRequestRequirement = declaration.memberBlock.members.contains {
            return $0.decl.as(VariableDeclSyntax.self)?.name?.text == "request"
        }
        if !hasRequestRequirement {
            throw RequestMacroDiagnostic.missingRequestDeclaration
        }
    }
    
    private static func getModifiers(
        declaration: some DeclGroupSyntax
    ) -> [any RequestMacroModifier] {
        var modifiers = [any RequestMacroModifier]()
        for member in declaration.memberBlock.members {
            guard let decl = member.decl.as(VariableDeclSyntax.self),
                  let declName = decl.name
            else {continue}
            
            let declMods = decl.attributes
                .compactMap { attribute -> (any RequestMacroModifier)? in
                    guard let name = attribute.name?.trimmed,
                          let type = RequestModifierType(rawValue: name.text)
                    else {
                        return nil
                    }
                    
                    let argument = attribute.attribute?.arguments?.unnamed.first
                    let key = (argument ?? declName).trimmed.text
                    return type.modifier(key, value: declName.trimmed)
                }
            modifiers.append(contentsOf: declMods)
        }
        return modifiers
    }
}

// MARK: - MemberMacro
extension RequestMacro: MemberMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try validateRequest(declaration: declaration)
        let reqMods = getModifiers(declaration: declaration)
        
        var declarations = [DeclSyntax]()
        
        if !reqMods.isEmpty {
            declarations.append(
                DeclarationsFactory.makeModDecl(
                    modifiers: declaration.modifiers.filter({$0.name.isAccessLevel}),
                    reqMods: reqMods
                )
            )
        }
        let hasIDProperty = declaration.memberBlock.members
            .contains { member in
                let varDecl = member.decl.as(VariableDeclSyntax.self)
                return varDecl?.name?.text == "id"
            }
        
        if !hasIDProperty,
           let id = node.arguments?.unnamed.first ?? declaration.typeName
        {
            declarations.append(
                DeclarationsFactory.makeIDDecl(
                    modifiers: declaration.modifiers,
                    id: id.text
                )
            )
        }
        if let funcDecl = DynamicConfigDeclFactory.make(for: declaration) {
            declarations.append(DeclSyntax(funcDecl))
        }
        return declarations
    }
}

// MARK: - ExtensionMacro
extension RequestMacro: ExtensionMacro {
    internal static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        var declarations = [
            DeclarationsFactory.makeExtensionDecl(type, name: "Request")
        ]
        
        if !getModifiers(declaration: declaration).isEmpty {
            declarations.append(
                DeclarationsFactory.makeExtensionDecl(type, name: "_ModifiableRequest")
            )
        }
        return declarations
    }
}
