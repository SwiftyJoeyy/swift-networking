//
//  ClientMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntax
import SwiftDiagnostics

package enum ClientMacroError: Error, Equatable {
    case missingSessionDeclaration
    case unexpectedSessionDeclaration
}

extension ClientMacroError: DiagnosticMessage {
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros.ClientMacro", id: "\(self)")
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return .error
    }
    
    /// The diagnostic messages.
    package var message: String {
        switch self {
        case .missingSessionDeclaration:
            return "Property 'session' is required to conform to protocol 'NetworkClient'"
        case .unexpectedSessionDeclaration:
            return "Unexpected '_session' property declaration"
        }
    }
}
