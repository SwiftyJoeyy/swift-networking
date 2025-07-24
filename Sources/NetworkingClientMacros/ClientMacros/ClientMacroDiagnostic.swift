//
//  ClientMacroDiagnostic.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntax
import SwiftDiagnostics

internal enum ClientMacroDiagnostic: Error {
    case missingSessionDeclaration
    case unexpectedSessionDeclaration
}

extension ClientMacroDiagnostic: DiagnosticMessage {
    /// The diagnostic messages.
    internal var message: String {
        switch self {
            case .missingSessionDeclaration:
                return "Property 'session' is required to conform to protocol 'NetworkClient'"
            case .unexpectedSessionDeclaration:
                return "Unexpected '_session' property declaration"
        }
    }
    
    /// The unique identifier for the diagnostic message.
    internal var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros", id: "Client.\(self)")
    }
    
    /// The severity level of the diagnostic message.
    internal var severity: DiagnosticSeverity {
        return .error
    }
}
