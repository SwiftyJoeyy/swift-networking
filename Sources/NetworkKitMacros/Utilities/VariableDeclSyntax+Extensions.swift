//
//  VariableDeclSyntax+Extensions.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntax

extension VariableDeclSyntax {
    public var name: TokenSyntax? {
        let binding = bindings.first
        let pattern = binding?.pattern.as(IdentifierPatternSyntax.self)
        return pattern?.identifier
    }
}
