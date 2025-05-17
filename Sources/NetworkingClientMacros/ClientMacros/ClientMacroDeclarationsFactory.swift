//
//  ClientMacroDeclarationsFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 2/25/25.
//

import SwiftSyntax

extension ClientMacro {
    package enum DeclarationsFactory { }
}

extension ClientMacro.DeclarationsFactory {
    package static func makeSessionDecl(
        _ modifiers: DeclModifierListSyntax
    ) -> DeclSyntax {
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "_session"),
            typeAnnotation: TypeAnnotationSyntax(
                type: ImplicitlyUnwrappedOptionalTypeSyntax(
                    wrappedType: IdentifierTypeSyntax(name: "Session")
                )
            )
        )
        let varDecl = VariableDeclSyntax(
            modifiers: modifiers,
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
    
    package static func makeInitDecl(
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
