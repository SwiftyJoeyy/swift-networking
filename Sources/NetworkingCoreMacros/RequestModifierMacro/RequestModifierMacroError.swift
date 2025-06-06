//
//  RequestModifierMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 5/28/25.
//

import SwiftSyntax
import SwiftDiagnostics

internal enum RequestModifierMacroDiagnostic: Error {
    case invalidConformance(typeName: String)
}

// MARK: - DiagnosticMessage
extension RequestModifierMacroDiagnostic: DiagnosticMessage {
    /// The diagnostic messages.
    internal var message: String {
        switch self {
            case .invalidConformance(let typeName):
                return "Type '\(typeName)' does not conform to protocol 'RequestModifier'"
        }
    }
    
    /// The unique identifier for the diagnostic message.
    internal var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros", id: "RequestModifier.\(self)")
    }
    
    /// The severity level of the diagnostic message.
    internal var severity: DiagnosticSeverity {
        return .error
    }
}
