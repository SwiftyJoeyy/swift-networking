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
    /// Decodes a variable binding from a given declaration.
    ///
    /// - Parameter declaration: The declaration syntax.
    ///
    /// - Returns: The binding element.
    ///
    /// - Throws: ``ConfigurationKeyMacroError.invalidPropertyType``
    /// if the declaration is not a variable declaration of type `var`.
    ///
    /// - Throws: ``ConfigurationKeyMacroError.invalidDeclaration``
    /// if the declaration is invalid.
    internal static func binding(
        for declaration: some DeclSyntaxProtocol
    ) throws -> PatternBindingListSyntax.Element {
        guard let variableDeclarations = declaration.as(VariableDeclSyntax.self),
              variableDeclarations.bindingSpecifier.text == "var"
        else {
            throw ConfigurationKeyMacroError.invalidPropertyType
        }
        guard let binding = variableDeclarations.bindings.first else {
            throw ConfigurationKeyMacroError.invalidDeclaration
        }
        return binding
    }
    
    /// Creates a struct key name from a property name & a protocol.
    ///
    /// Using `text = ""` as the binding from the code below,
    /// & `ConfigurationKey`  as the protocolName, this function
    /// produces `ConfigurationKey_text`.
    ///
    /// - Parameter binding: The binding element.
    ///
    /// - Returns: The struct key name.
    ///
    /// - Throws: ``ConfigurationKeyMacroError.invalidDeclaration``
    /// if the binding is invalid.
    internal static func keyName(
        for binding: PatternBindingListSyntax.Element
    ) throws -> TokenSyntax {
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw ConfigurationKeyMacroError.invalidDeclaration
        }
        
        let name = pattern.identifier.text
        return "ConfigurationKey_\(raw: name)" as TokenSyntax
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
            let binding = try binding(for: declaration)
            let keyName = try keyName(for: binding)
            
            return [
                """
                get {
                    return self[\(keyName).self]
                }
                """,
                """
                set(newValue) {
                self[\(keyName).self] = newValue
                }
                """
            ]
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
            var binding = try binding(for: declaration)
            let keyName = try keyName(for: binding)
            let syntax = IdentifierPatternSyntax(identifier: .identifier("defaultValue "))
            binding.pattern = PatternSyntax(syntax)
            
            let defaultValue = binding.initializer != nil
            guard defaultValue else {
                throw ConfigurationKeyMacroError.missingDefaultValue
            }
            
            return [
                """
                fileprivate struct \(keyName): ConfigurationKey {
                    fileprivate static let \(binding)
                }
                """
            ]
        }
    }
}
