//
//  RequestMacroDeclarationsFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/21/25.
//

import SwiftSyntax

internal enum RequestModifierType: String {
    case header = "Header"
    case parameter = "Parameter"
}

internal struct RequestMacroModifier {
    internal let type: RequestModifierType
    internal let name: String
    internal let value: String
    internal let isOptional: Bool
}

extension RequestMacro {
    /// Factory for creating declarations for the ``RequestMacro``.
    internal enum DeclarationsFactory { }
}

// MARK: - Functions
extension RequestMacro.DeclarationsFactory {
    private static func makeModifierGroups(
        with modifiers: [RequestMacroModifier]
    ) -> [ArrayElementSyntax] {
        var headers = DictionaryElementListSyntax()
        var parameters = ArrayElementListSyntax()
        
        for modifier in modifiers {
            switch modifier.type {
            case .header:
                let element = DictionaryElementSyntax(
                    leadingTrivia: headers.isEmpty ? .newline: nil,
                    key: StringLiteralExprSyntax(content: modifier.name),
                    value: DeclReferenceExprSyntax(baseName: "\(raw: modifier.value)"),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                )
                headers.append(element)
            case .parameter:
                let valueExpression = LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(modifier.value)
                        )
                    )
                }
                let element = ArrayElementSyntax(
                    leadingTrivia: parameters.isEmpty ? .newline: nil,
                    expression: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: "URLQueryItem"),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: "name",
                                expression: StringLiteralExprSyntax(content: modifier.name)
                            )
                            LabeledExprSyntax(
                                label: "value",
                                expression: FunctionCallExprSyntax(
                                    calledExpression: DeclReferenceExprSyntax(baseName: "String"),
                                    leftParen: .leftParenToken(),
                                    arguments: valueExpression,
                                    rightParen: .rightParenToken()
                                )
                            )
                        },
                        rightParen: .rightParenToken()
                    ),
                    trailingComma: .commaToken(),
                    trailingTrivia: .newline
                )
                parameters.append(element)
            }
        }
        var items = [ArrayElementSyntax]()
        if !headers.isEmpty {
            items.append(
                makeArraySyntax(
                    name: "HeadersGroup",
                    expression: DictionaryExprSyntax(
                        content: .elements(headers)
                    ),
                    trailingTrivia: parameters.isEmpty ? .newline: nil
                )
            )
        }
        if !parameters.isEmpty {
            items.append(
                makeArraySyntax(
                    name: "ParametersGroup",
                    expression: ArrayExprSyntax(elements: parameters)
                )
            )
        }
        return items
    }
    private static func makeArraySyntax(
        name: TokenSyntax,
        expression: some ExprSyntaxProtocol,
        trailingTrivia: Trivia? = .newline
    ) -> ArrayElementSyntax {
        let labeledExpr = LabeledExprSyntax(
            leadingTrivia: .newline,
            expression: expression,
            trailingTrivia: .newline
        )
        return ArrayElementSyntax(
            expression: FunctionCallExprSyntax(
                leadingTrivia: .newline,
                calledExpression: DeclReferenceExprSyntax(baseName: name),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax([labeledExpr]),
                rightParen: .rightParenToken()
            ),
            trailingComma: .commaToken(),
            trailingTrivia: trailingTrivia
        )
    }
    private static func makeAccessModifier(
        _ accessLevel: TokenSyntax?
    ) -> DeclModifierListSyntax {
        guard let accessLevel else {
            return []
        }
        return [DeclModifierSyntax(name: accessLevel)]
    }
    
    internal static func makeModifiersDecl(
        accessLevel: TokenSyntax?,
        modifiers: [RequestMacroModifier]
    ) -> DeclSyntax {
        let stmtSyntax = StmtSyntax(
            ReturnStmtSyntax(
                expression: ArrayExprSyntax(
                    elements: ArrayElementListSyntax(
                        makeModifierGroups(with: modifiers)
                    )
                )
            )
        )
        let accessors = [
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.get),
                body: CodeBlockSyntax {
                    CodeBlockItemSyntax(item: .stmt(stmtSyntax))
                }
            ),
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.set),
                body: CodeBlockSyntax(
                    leftBrace: .leftBraceToken(),
                    statements: CodeBlockItemListSyntax(),
                    rightBrace: .rightBraceToken()
                )
            )
        ]
        let type = ArrayTypeSyntax(
            element: SomeOrAnyTypeSyntax(
                someOrAnySpecifier: .keyword(.any),
                constraint: IdentifierTypeSyntax(name: "RequestModifier")
            )
        )
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "_modifiers"),
            typeAnnotation: TypeAnnotationSyntax(
                type: type
            ),
            accessorBlock: AccessorBlockSyntax(
                accessors: .accessors(AccessorDeclListSyntax(accessors))
            )
        )
        let varDecl = VariableDeclSyntax(
            modifiers: makeAccessModifier(accessLevel),
            bindingSpecifier: .keyword(.var),
            bindings: [binding]
        )
        
        return DeclSyntax(varDecl)
    }
    
    internal static func makeIDDecl(
        accessLevel: TokenSyntax?,
        id: String
    ) -> DeclSyntax {
        let binding = PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: "id"),
            typeAnnotation: TypeAnnotationSyntax(
                type: OptionalTypeSyntax(
                    wrappedType: IdentifierTypeSyntax(name: "String")
                )
            ),
            initializer: InitializerClauseSyntax(
                value: StringLiteralExprSyntax(content: id)
            )
        )
        let letDecl = VariableDeclSyntax(
            modifiers: makeAccessModifier(accessLevel),
            bindingSpecifier: .keyword(.let),
            bindings: [binding]
        )
        return DeclSyntax(letDecl)
    }
    
    internal static func makeExtensionDecl(
        _ type: some TypeSyntaxProtocol
    ) -> ExtensionDeclSyntax {
        let inheritedType = InheritedTypeSyntax(
            type: IdentifierTypeSyntax(name: "Request")
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
