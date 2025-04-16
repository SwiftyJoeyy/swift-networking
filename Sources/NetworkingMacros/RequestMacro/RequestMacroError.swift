//
//  RequestMacroError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntax
import SwiftDiagnostics
import MacrosKit

package enum RequestMacroError: MacroError, Equatable {
    case missingRequestDeclaration
}

extension RequestMacroError {
    /// The diagnostic messages.
    package var message: String {
        switch self {
            case .missingRequestDeclaration:
                return "Property 'request' is required to conform to protocol 'Request'"
        }
    }
}
