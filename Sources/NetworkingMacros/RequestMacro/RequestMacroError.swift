//
//  RequestMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftDiagnostics

package enum RequestMacroError: Error, Equatable {
    case missingRequestDeclaration
}

// MARK: - DiagnosticMessage
extension RequestMacroError: DiagnosticMessage {
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros.RequestMacro", id: "\(self)")
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return .error
    }
    
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .missingRequestDeclaration:
                return "Property 'request' is required to conform to protocol 'Request'"
        }
    }
}
