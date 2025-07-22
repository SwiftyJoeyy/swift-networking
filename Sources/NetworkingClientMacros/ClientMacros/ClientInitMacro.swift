//
//  ClientInitMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 2/25/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

internal enum ClientInitMacro: BodyMacro {
    private static let functionName = "configure"
    internal static let name: TokenSyntax = "NetworkingClient.ClientInit"
    
    internal static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        var statements = Array(declaration.body!.statements)
        let containsConfigureCall = statements.contains { statement in
            let name = statement.item.as(FunctionCallExprSyntax.self)?
                .calledExpression
                .as(DeclReferenceExprSyntax.self)?
                .baseName
                .text
            return name == functionName
        }
        guard !containsConfigureCall else {
            return statements
        }
        let statement = CodeBlockItemSyntax(
            item: .expr(
                ExprSyntax(
                    FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(
                            baseName: .identifier(functionName)
                        ),
                        leftParen: .leftParenToken(),
                        arguments: [],
                        rightParen: .rightParenToken(),
                        additionalTrailingClosures: []
                    )
                )
            )
        )
        statements.append(statement)
        return statements
    }
}
