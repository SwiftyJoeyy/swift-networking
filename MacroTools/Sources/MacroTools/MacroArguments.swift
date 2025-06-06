//
//  MacroArguments.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

/// Factory for getting the value of an ``ExprSyntax``.
internal enum ArgumentFactory {
    /// Creates a ``TokenSyntax`` from the given macro argument.
    ///
    /// This method supports several expression types:
    /// - ``StringLiteralExprSyntax``.
    /// - ``MemberAccessExprSyntax``.
    /// - ``KeyPathExprSyntax``.
    /// - ``BooleanLiteralExprSyntax``.
    ///
    /// - Parameter syntax: The expression syntax to convert.
    ///
    /// - Returns: A ``TokenSyntax`` representing the given macro argument,
    /// or ``nil`` if the expression type is unsupported.
    internal static func make(for syntax: ExprSyntax) -> TokenSyntax? {
        if let stringExpression = syntax.as(StringLiteralExprSyntax.self),
           let segment = stringExpression.segments.first,
           let value = segment.as(StringSegmentSyntax.self)?.content
        {
            return value
        }
        
        if let memberExpression = syntax.as(MemberAccessExprSyntax.self) {
            let base = memberExpression.base?.as(DeclReferenceExprSyntax.self)
            return base?.baseName ?? memberExpression.declName.baseName
        }
        
        if let keyPathExpression = syntax.as(KeyPathExprSyntax.self),
           let firstComponent = keyPathExpression.components.first?.component,
           let component = firstComponent.as(KeyPathPropertyComponentSyntax.self)
        {
            return component.declName.baseName
        }
        
        if let boolExpression = syntax.as(BooleanLiteralExprSyntax.self) {
            return boolExpression.literal
        }
        
        return nil
    }
}

extension AttributeSyntax.Arguments {
    /// The named macro arguments.
    public var named: [String: TokenSyntax] {
        guard let arguments = self.as(LabeledExprListSyntax.self) else {
            return [:]
        }
        var dictionary = [String: TokenSyntax]()
        
        for argument in arguments {
            guard let name = argument.label?.text else {continue}
            dictionary[name] = ArgumentFactory.make(for: argument.expression)
        }
        
        return dictionary
    }
    
    /// The unnamed macro arguments.
    public var unnamed: [TokenSyntax] {
        guard let arguments = self.as(LabeledExprListSyntax.self) else {
            return []
        }
        return arguments.compactMap { argument in
            guard argument.label?.text == nil else {
                return nil
            }
            return ArgumentFactory.make(for: argument.expression)
        }
    }
}
