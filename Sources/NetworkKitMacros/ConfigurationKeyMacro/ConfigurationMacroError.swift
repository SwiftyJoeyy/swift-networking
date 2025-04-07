//
//  ConfigurationMacroError.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics
import MacrosKit

/// Errors that can occur during the processing of ``KeyMacro``.
package enum ConfigurationKeyMacroError: MacroError {
    /// The property type is invalid for the applied macro.
    case invalidPropertyType
    
    /// The property declaration is invalid.
    case invalidDeclaration
    
    /// The property declaration is missing a default value
    /// or an explicitly stated getter.
    case missingDefaultValue
    
    /// The property declaration is missing a type annotation.
    case missingTypeAnnotation
    
    /// The property's type is not optional.
    case invalidOptionalTypeAnnotation
}

extension ConfigurationKeyMacroError {
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .invalidPropertyType:
                return "The applied macro is only valid for 'var' properties"
            case .invalidDeclaration:
                return "Invalid property declaration"
            case .missingDefaultValue:
                return "Property declaration requires an initializer expression or an explicitly stated getter"
            case .missingTypeAnnotation:
                return "Property declaration requires an optional type annotation"
            case .invalidOptionalTypeAnnotation:
                return "Property type must be optional"
        }
    }
}
