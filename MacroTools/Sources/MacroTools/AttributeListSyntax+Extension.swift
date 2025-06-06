//
//  AttributeListSyntax+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

extension AttributeListSyntax.Element {
    /// The attribute syntax .
    ///
    /// - Returns: An optional ``AttributeSyntax`` representing the attribute syntax,
    /// or ``nil`` if the node is not an attribute syntax.
    public var attribute: AttributeSyntax? {
        return self.as(AttributeSyntax.self)
    }
    
    /// The name of the attribute.
    ///
    /// - Returns: An optional ``TokenSyntax`` representing the name of the attribute,
    /// or ``nil`` if the name cannot be determined.
    public var name: TokenSyntax? {
        let attributeName = attribute?.attributeName.as(IdentifierTypeSyntax.self)
        return attributeName?.name
    }
}
