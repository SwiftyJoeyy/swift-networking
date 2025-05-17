//
//  RequestMacroModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import SwiftSyntax

internal protocol RequestMacroModifier {
    func make() -> CodeBlockItemSyntax
}

internal struct HeaderMacroModifier: RequestMacroModifier {
    internal let key: StringLiteralExprSyntax
    internal let value: TokenSyntax
    
    internal func make() -> CodeBlockItemSyntax {
        return "Header(\(key), value: \(value))"
    }
}

internal struct ParameterMacroModifier: RequestMacroModifier {
    internal let name: StringLiteralExprSyntax
    internal let value: TokenSyntax
    
    internal func make() -> CodeBlockItemSyntax {
        return "Parameter(\(name), value: \(value))"
    }
}

internal struct ParametersListMacroModifier: RequestMacroModifier {
    internal let name: StringLiteralExprSyntax
    internal let value: TokenSyntax
    
    internal func make() -> CodeBlockItemSyntax {
        return "Parameter(\(name), values: \(value))"
    }
}

internal enum RequestModifierType: String {
    case header = "Header"
    case parameter = "Parameter"
    
    internal func modifier(
        _ key: String,
        value: TokenSyntax
    ) -> any RequestMacroModifier {
        let key = StringLiteralExprSyntax(content: key)
        switch self {
            case .header:
                return HeaderMacroModifier(key: key, value: value)
            case .parameter:
                return ParameterMacroModifier(name: key, value: value)
        }
    }
}
