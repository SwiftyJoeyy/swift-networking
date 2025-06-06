//
//  RequestMacroDiagnostic.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftDiagnostics

internal enum RequestMacroDiagnostic: Error, Equatable {
    case missingRequestDeclaration
}

// MARK: - DiagnosticMessage
extension RequestMacroDiagnostic: DiagnosticMessage {
    /// The diagnostic messages.
    internal var message: String {
        switch self {
            case .missingRequestDeclaration:
                return "Property 'request' is required to conform to protocol 'Request'"
        }
    }
    
    /// The unique identifier for the diagnostic message.
    internal var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros", id: "Request.\(self)")
    }
    
    /// The severity level of the diagnostic message.
    internal var severity: DiagnosticSeverity {
        return .error
    }
}
