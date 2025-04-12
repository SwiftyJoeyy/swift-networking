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
    case missingSessionDeclaration
    case unexpectedSessionDeclaration
}

extension ClientMacroError {
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
