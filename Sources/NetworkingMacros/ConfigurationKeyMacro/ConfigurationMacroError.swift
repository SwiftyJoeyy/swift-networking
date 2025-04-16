//
//  ConfigurationMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntax
import SwiftDiagnostics

/// Errors that can occur during the processing of ``KeyMacro``.
package enum ConfigurationKeyMacroError: Error {
    /// The property type is invalid for the applied macro.
    case invalidPropertyType
    
    /// The property declaration is missing an initializer
    /// or an explicitly stated getter.
    case missingInitializer
    
    /// The property declaration is missing a type annotation.
    case missingTypeAnnotation
}

extension ConfigurationKeyMacroError: DiagnosticMessage {
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros.ConfigurationKeyMacro", id: "\(self)")
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return .error
    }
    
    /// The diagnostic messages.
    package var message: String {
        switch self {
        case .invalidPropertyType:
            return "The applied macro is only valid for 'var' properties"
        case .missingInitializer:
            return "Property declaration requires an initializer expression or an explicitly stated getter"
        case .missingTypeAnnotation:
            return "Property declaration requires an optional type annotation"
        }
    }
}
