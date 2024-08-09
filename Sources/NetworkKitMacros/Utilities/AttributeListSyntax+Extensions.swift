//
//  AttributeListSyntax+Extensions.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntax

extension AttributeListSyntax.Element {
    public var name: TokenSyntax? {
        let attribute = self.as(AttributeSyntax.self)
        let attributeName = attribute?.attributeName.as(IdentifierTypeSyntax.self)
        return attributeName?.name
    }
    public var argumentName: TokenSyntax? {
        let arguments = self.as(AttributeSyntax.self)?.arguments
        let expression = arguments?.as(LabeledExprListSyntax.self)?.first?.expression
        let segment = expression?.as(StringLiteralExprSyntax.self)?.segments.first
        let attributeName = segment?.as(StringSegmentSyntax.self)?.content
        return attributeName
    }
}
