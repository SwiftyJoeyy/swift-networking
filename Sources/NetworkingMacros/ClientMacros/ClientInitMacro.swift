//
//  ClientInitMacro.swift
//  Networking
//
//  Created by Joe Maghzal on 2/25/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

package enum ClientInitMacro: BodyMacro {
    private static let functionName = "configure"
    package static let name: TokenSyntax = "ClientInit"
    
    package static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        var statements = Array(declaration.body!.statements)
        let containsConfigureCall = statements.contains { statement in
            let functionCall = statement.item.as(FunctionCallExprSyntax.self)
            let name = functionCall?.calledExpression
                .as(DeclReferenceExprSyntax.self)?
                .baseName
                .text
            return name == functionName
        }
        guard !containsConfigureCall else {
            return statements
        }
        let functionCallSyntax = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(functionName)
            ),
            leftParen: .leftParenToken(),
            arguments: [],
            rightParen: .rightParenToken(),
            additionalTrailingClosures: []
        )
        let statement = CodeBlockItemSyntax(
            item: .expr(ExprSyntax(functionCallSyntax))
        )
        statements.append(statement)
        return statements
    }
}
