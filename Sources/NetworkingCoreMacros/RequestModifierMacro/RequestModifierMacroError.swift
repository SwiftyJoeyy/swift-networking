//
//  RequestModifierMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 5/28/25.
//

import SwiftSyntax
import SwiftDiagnostics

extension RequestModifierMacro {
    package enum Message: Error, Equatable {
        case invalidConformance(typeName: String)
        //    case invalidMemberDecl
    }
}

// MARK: - DiagnosticMessage
extension RequestModifierMacro.Message: DiagnosticMessage {
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros.RequestModifierMacro", id: "\(self)")
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return .error
    }
    
    /// The diagnostic messages.
    package var message: String {
        switch self {
        case .invalidConformance(let typeName):
            return "Type '\(typeName)' does not conform to protocol 'RequestModifier'"
        }
    }
}
