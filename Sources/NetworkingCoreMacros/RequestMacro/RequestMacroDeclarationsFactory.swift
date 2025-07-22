//
//  RequestMacroDeclarationsFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 2/21/25.
//

import SwiftSyntax

extension RequestMacro {
    /// Factory for creating declarations for the ``RequestMacro``.
    internal enum DeclarationsFactory { }
}

// MARK: - Functions
extension RequestMacro.DeclarationsFactory {
    internal static func makeModDecl(
        modifiers: DeclModifierListSyntax,
        reqMods: [any RequestMacroModifier]
    ) -> DeclSyntax {
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "modifier"),
            typeAnnotation: TypeAnnotationSyntax(
                type: SomeOrAnyTypeSyntax(
                    someOrAnySpecifier: .keyword(.some),
                    constraint: IdentifierTypeSyntax(name: "NetworkingCore.RequestModifier")
                )
            ),
            accessorBlock: AccessorBlockSyntax(
                accessors: .getter(
                    CodeBlockItemListSyntax(reqMods.map({$0.make()}))
                )
            )
        )
        let decl = VariableDeclSyntax(
            attributes: [
                .attribute(
                    AttributeSyntax(
                        attributeName: IdentifierTypeSyntax(
                            name: .identifier("NetworkingCore.ModifiersBuilder")
                        )
                    )
                )
            ],
            modifiers: modifiers,
            bindingSpecifier: .keyword(.var),
            bindings: [binding]
        )
        return DeclSyntax(decl)
    }
    
    internal static func makeIDDecl(
        modifiers: DeclModifierListSyntax,
        id: String
    ) -> DeclSyntax {
        let decl = VariableDeclSyntax(
            modifiers: modifiers,
            bindingSpecifier: .keyword(.let),
            bindings: [
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "id"),
                    initializer: InitializerClauseSyntax(
                        value: StringLiteralExprSyntax(content: id)
                    )
                )
            ]
        )
        return DeclSyntax(decl)
    }
    
    internal static func makeExtensionDecl(
        _ type: some TypeSyntaxProtocol,
        name: TokenSyntax
    ) -> ExtensionDeclSyntax {
        let decl = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(name: name)
                    )
                ]
            )
        ) { }
        return decl
    }
}
