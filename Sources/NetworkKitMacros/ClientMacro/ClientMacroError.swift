//
//  ClientMacroError.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntax
import SwiftDiagnostics

package enum ClientMacroError: MacroError, Equatable {
    case missingCommandDeclaration
}

extension ClientMacroError {
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .missingCommandDeclaration:
                return "Property 'command' is required to conform to 'NetworkingClient'"
        }
    }
}
