//
//  VariableDeclSyntax+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

extension VariableDeclSyntax {
    public var name: TokenSyntax? {
        let binding = bindings.first
        let pattern = binding?.pattern.as(IdentifierPatternSyntax.self)
        return pattern?.identifier
    }
}
