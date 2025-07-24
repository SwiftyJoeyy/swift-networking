//
//  ConfigurationMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit

internal enum ConfigurationKeyMacro {
    private static func validateProperyContext(
        context: some MacroExpansionContext
    ) throws {
        for syntax in context.lexicalContext {
            if let extDecl = syntax.as(ExtensionDeclSyntax.self),
               let type = extDecl.extendedType.as(IdentifierTypeSyntax.self),
               type.name.text == "ConfigurationValues" {
                return
            }
        }
        throw ConfigurationKeyMacroDiagnostic.invalidDeclarationContext
    }
    private static func validatedDeclType(
        _ decl: VariableDeclSyntax
    ) throws {
        guard decl.bindingSpecifier.tokenKind != .keyword(.var) else {return}
        let diag = ConfigurationKeyMacroDiagnostic.invalidPropertyType
            .diagnose(at: Syntax(decl))
            .fixIt { diag in
                FixIt(
                    message: MacroFixItMessage(
                        message: "Replace 'let' with 'var'",
                        fixItID: diag.diagnosticID
                    ),
                    changes: [
                        .replace(
                            oldNode: Syntax(decl.bindingSpecifier),
                            newNode: Syntax(TokenSyntax("var "))
                        )
                    ]
                )
            }
        throw diag.error
    }
    private static func declInfo(
        for decl: VariableDeclSyntax
    ) -> (
        binding: PatternBindingSyntax,
        forced: Bool,
        propertyName: PatternSyntax,
        type: TypeSyntax?
    ) {
        let binding = decl.bindings.first!
        let type = binding.typeAnnotation?.type
        let forced = type?.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) == true
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
    internal static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let decl = declaration.as(VariableDeclSyntax.self)!
        try validatedDeclType(decl)
        let info = declInfo(for: decl)
        
        if info.forced {
            let type = info.type?.as(ImplicitlyUnwrappedOptionalTypeSyntax.self)
            return DeclarationsFactory.makeUnwrappedAccessors(
                propertyName: info.propertyName,
                type: type?.wrappedType
            )
        }
        return DeclarationsFactory.makeAccessors(from: info.propertyName)
    }
}

// MARK: - PeerMacro
extension ConfigurationKeyMacro: PeerMacro {
    /// Generates the key struct for the given declaration.
    internal static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try validateProperyContext(context: context)
        guard let decl = declaration.as(VariableDeclSyntax.self) else {
            throw ConfigurationKeyMacroDiagnostic.invalidPropertyType
        }
        let info = declInfo(for: decl)
        
        let optional = info.type?.is(OptionalTypeSyntax.self) == true
        let requiredInit = info.forced || optional
        if !requiredInit && info.binding.initializer == nil {
            throw ConfigurationKeyMacroDiagnostic.missingInitializer
        }
        
        return DeclarationsFactory.makeKeyDecl(
            propertyName: info.propertyName,
            binding: info.binding,
            addNilLiteral: requiredInit
        )
    }
}
