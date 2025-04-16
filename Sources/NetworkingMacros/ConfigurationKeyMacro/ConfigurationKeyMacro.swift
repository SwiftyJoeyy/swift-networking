//
//  ConfigurationMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import MacrosKit

package enum ConfigurationKeyMacro {
    private static let forceArgument = "forceUnwrapped"
    
    private static func declInfo(
        of node: AttributeSyntax,
        declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> (
        binding: PatternBindingSyntax,
        forced: Bool,
        propertyName: PatternSyntax,
        type: TypeSyntax?
    ) {
        guard let decl = declaration.as(VariableDeclSyntax.self),
              decl.bindingSpecifier.tokenKind == .keyword(.var)
        else {
            throw ConfigurationKeyMacroError.invalidPropertyType
        }
        
        let binding = decl.bindings.first!
        
        let arguments = node.arguments?.named
        let forced = arguments?[forceArgument]?.tokenKind == .keyword(.true)
        let type = binding.typeAnnotation?.type
        
        if forced && type == nil {
            throw ConfigurationKeyMacroError.missingTypeAnnotation
        }
        
        return (
            binding: binding,
            forced: forced,
            propertyName: binding.pattern.trimmed,
            type: type
        )
    }
}

// MARK: - AccessorMacro
extension ConfigurationKeyMacro: AccessorMacro {
    /// Generates the computed property for the given declaration,
    /// allowing access to the generated key struct.
    package static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let info = try declInfo(of: node, declaration: declaration, in: context)
        if info.forced {
            return DeclarationsFactory.makeUnwrappedAccessors(
                propertyName: info.propertyName,
                type: info.type
            )
        }
        return DeclarationsFactory.makeAccessors(from: info.propertyName)
    }
}

// MARK: - PeerMacro
extension ConfigurationKeyMacro: PeerMacro {
    /// Generates the key struct for the given declaration.
    package static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let info = try declInfo(of: node, declaration: declaration, in: context)
        let optional = info.type?.is(OptionalTypeSyntax.self) == true
        if !info.forced && info.binding.initializer == nil && !optional {
            throw ConfigurationKeyMacroError.missingInitializer
        }
        
        return DeclarationsFactory.makeKeyDecl(
            propertyName: info.propertyName,
            binding: info.binding,
            forced: info.forced,
            optional: optional
        )
    }
}
