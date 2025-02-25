//
//  ClientMacroDeclarationsFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/25/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import MacrosKit
import Foundation

extension ClientMacro {
    package enum DeclarationsFactory { }
}

extension ClientMacro.DeclarationsFactory {
    package static func makeCommandDecl(
        _ accessLevel: TokenSyntax?
    ) -> DeclSyntax {
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "_command"),
            typeAnnotation: TypeAnnotationSyntax(
                type: ImplicitlyUnwrappedOptionalTypeSyntax(
                    wrappedType: IdentifierTypeSyntax(name: "RequestCommand")
                )
            )
        )
        let varDecl = VariableDeclSyntax(
            modifiers: makeAccessModifier(accessLevel),
            bindingSpecifier: .keyword(.var),
            bindings: [binding]
        )
        return DeclSyntax(varDecl)
    }
    
    package static func makeInitAttribute() -> AttributeSyntax {
        return AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: ClientInitMacro.name)
        )
    }
    
    package static func makeAccessModifier(
        _ accessLevel: TokenSyntax?
    ) -> DeclModifierListSyntax {
        guard let accessLevel else {
            return []
        }
        return [DeclModifierSyntax(name: accessLevel.trimmed)]
    }
    
    package static func makeInitDecl(
        _ accessLevel: TokenSyntax?
    ) -> DeclSyntax {
        let declaration = InitializerDeclSyntax(
            attributes: [.attribute(makeInitAttribute())],
            modifiers: makeAccessModifier(accessLevel),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(parameters: [])
            ),
            body: CodeBlockSyntax(statements: [])
        )
        return DeclSyntax(declaration)
    }
    
    package static func makeExtensionDecl(
        _ type: some TypeSyntaxProtocol
    ) -> ExtensionDeclSyntax {
        let inheritedType = InheritedTypeSyntax(
            type: IdentifierTypeSyntax(name: "NetworkClient")
        )
        let declaration = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [inheritedType]
            )
        ) { }
        return declaration
    }
}
