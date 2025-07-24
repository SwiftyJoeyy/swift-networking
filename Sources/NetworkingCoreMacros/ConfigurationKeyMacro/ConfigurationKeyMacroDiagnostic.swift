//
//  ConfigurationKeyMacroDiagnostic.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntax
import SwiftDiagnostics

/// Errors that can occur during the processing of ``KeyMacro``.
internal enum ConfigurationKeyMacroDiagnostic: Error {
    /// The property type is invalid for the applied macro.
    case invalidPropertyType
    
    /// The property declaration is missing an initializer
    /// or an explicitly stated getter.
    case missingInitializer
    
    /// The property is not declared in an extension of ConfigurationValues.
    case invalidDeclarationContext
}

extension ConfigurationKeyMacroDiagnostic: DiagnosticMessage {
    /// The diagnostic messages.
    internal var message: String {
        switch self {
            case .invalidPropertyType:
                return "'@Config' can only be applied to a 'var' declaration"
            case .missingInitializer:
                return "Property missing a default value"
            case .invalidDeclarationContext:
                return "'@Config' macro can only attach to var declarations inside an extension of ConfigurationValues"
        }
    }
    
    /// The unique identifier for the diagnostic message.
    internal var diagnosticID: MessageID {
        return MessageID(domain: "NetworkingMacros", id: "Configuration.\(self)")
    }
    
    /// The severity level of the diagnostic message.
    internal var severity: DiagnosticSeverity {
        return .error
    }
}
