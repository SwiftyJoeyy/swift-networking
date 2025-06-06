//
//  AccessLevel.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

public enum AccessLevel {
    public static var allCases: Set<TokenSyntax> {
        return [
            .keyword(.public),
            .keyword(.package),
            .keyword(.internal),
            .keyword(.private),
            .keyword(.fileprivate),
            .keyword(.open)
        ]
    }
}

extension TokenSyntax {
    public var isAccessLevel: Bool {
        guard case .keyword(let value) = tokenKind else {
            return false
        }
        
        switch value {
            case .public, .package, .internal, .private, .fileprivate, .open:
                return true
            default:
                return false
        }
    }
}
