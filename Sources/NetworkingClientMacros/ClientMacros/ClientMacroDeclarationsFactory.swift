//
//  ClientMacroDeclarationsFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 2/25/25.
//

import SwiftSyntax

extension ClientMacro {
    internal enum DeclarationsFactory { }
}

extension ClientMacro.DeclarationsFactory {
    internal static func makeSessionDecl(
        _ modifiers: DeclModifierListSyntax
    ) -> DeclSyntax {
        let varDecl = VariableDeclSyntax(
            modifiers: modifiers,
            bindingSpecifier: .keyword(.var),
            bindings: [
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "_session"),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: ImplicitlyUnwrappedOptionalTypeSyntax(
                            wrappedType: IdentifierTypeSyntax(name: "Session")
                        )
                    )
                )
            ]
        )
        return DeclSyntax(varDecl)
    }
    
    internal static func makeInitAttribute() -> AttributeSyntax {
        return AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: ClientInitMacro.name)
        )
    }
    
    internal static func makeInitDecl(
        _ modifiers: DeclModifierListSyntax
    ) -> DeclSyntax {
        let declaration = InitializerDeclSyntax(
            attributes: [.attribute(makeInitAttribute())],
            modifiers: modifiers,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(parameters: [])
            ),
            body: CodeBlockSyntax(statements: [])
        )
        return DeclSyntax(declaration)
    }
    
    internal static func makeExtensionDecl(
        _ type: some TypeSyntaxProtocol
    ) -> ExtensionDeclSyntax {
        let declaration = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(name: "NetworkClient")
                    )
                ]
            )
        ) { }
        return declaration
    }
}
