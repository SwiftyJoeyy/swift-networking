//
//  ConfigurationMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit

package enum ConfigurationKeyMacro {
    private static let forceArgument = "forceUnwrapped"
    private static func declInfo(
        for declaration: some DeclSyntaxProtocol
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
        
        let arguments = decl.attributes.first?.attribute?.arguments?.arguments
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
        try withErroHandling(context: context, node: node, onFailure: []) {
            let info = try declInfo(for: declaration)
            if info.forced {
                return DeclarationsFactory.makeUnwrappedAccessors(
                    propertyName: info.propertyName,
                    type: info.type
                )
            }
            return DeclarationsFactory.makeAccessors(from: info.propertyName)
        }
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
        try withErroHandling(context: context, node: node, onFailure: []) {
            let info = try declInfo(for: declaration)
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
}
