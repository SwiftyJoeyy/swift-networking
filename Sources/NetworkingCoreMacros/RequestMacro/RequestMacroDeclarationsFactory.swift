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
        let codeBlock = CodeBlockItemListSyntax(reqMods.map({$0.make()}))
        
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "modifier"),
            typeAnnotation: TypeAnnotationSyntax(
                type: SomeOrAnyTypeSyntax(
                    someOrAnySpecifier: .keyword(.some),
                    constraint: IdentifierTypeSyntax(name: "RequestModifier")
                )
            ),
            accessorBlock: AccessorBlockSyntax(accessors: .getter(codeBlock))
        )
        let attribute = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("ModifiersBuilder"))
        )
        let decl = VariableDeclSyntax(
            attributes: [
                .attribute(attribute)
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
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "id"),
            initializer: InitializerClauseSyntax(
                value: StringLiteralExprSyntax(content: id)
            )
        )
        let decl = VariableDeclSyntax(
            modifiers: modifiers,
            bindingSpecifier: .keyword(.let),
            bindings: [binding]
        )
        return DeclSyntax(decl)
    }
    
    internal static func makeExtensionDecl(
        _ type: some TypeSyntaxProtocol,
        name: TokenSyntax
    ) -> ExtensionDeclSyntax {
        let inheritedType = InheritedTypeSyntax(
            type: IdentifierTypeSyntax(name: name)
        )
        let decl = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [inheritedType]
            )
        ) { }
        return decl
    }
}
