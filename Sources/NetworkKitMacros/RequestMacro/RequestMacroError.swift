//
//  RequestMacroError.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntax
import SwiftDiagnostics

package enum RequestMacroError: MacroError, Equatable {
    /// The property declaration is invalid.
    case invalidDeclaration
    
    case missingRequestDeclaration
}

extension RequestMacroError {
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .invalidDeclaration:
                return "Invalid property declaration"
            case .missingRequestDeclaration:
                return "Property 'command' is required to conform to 'NetworkingClient'"
        }
    }
}
