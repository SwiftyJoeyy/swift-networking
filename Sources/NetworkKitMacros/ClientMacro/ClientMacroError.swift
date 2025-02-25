//
//  ClientMacroError.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntax

import SwiftSyntax
import SwiftDiagnostics
import MacrosKit

package enum ClientMacroError: MacroError, Equatable {
    case missingCommandDeclaration
    case unexpectedCommandDeclaration
}

extension ClientMacroError {
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .missingCommandDeclaration:
                return "Property 'command' is required to conform to protocol 'NetworkClient'"
        case .unexpectedCommandDeclaration:
            return "Unexpected '_command' property declaration"
        }
    }
}
