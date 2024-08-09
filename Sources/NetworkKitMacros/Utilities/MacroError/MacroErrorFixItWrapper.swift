//
//  MacroErrorFixItWrapper.swift
//
//
//  Created by Joe Maghzal on 06/05/2024.
//

import Foundation
import SwiftDiagnostics

/// Wrapper for ``MacroError`` providing associated fix its.
package struct MacroErrorFixItWrapper {
    /// The wrapped macro error.
    private let error: MacroError
    
    /// The additional associated fix its to add to the error's fix its..
    package let additionalFixIts: [FixIt]
}

//MARK: - Initializer
extension MacroErrorFixItWrapper {
    /// Creates a new ``MacroError`` with the provided error and additional fix its.
    /// 
    /// - Parameters:
    ///   - error: The error to be wrapped.
    ///   - fixIts: The additional associated fix its to add to the error's fix its.
    package init(error: MacroError, fixIts: [FixIt]) {
        self.error = error
        self.additionalFixIts = fixIts
    }
}

//MARK: - MacroError
extension MacroErrorFixItWrapper: MacroError {
    /// The associated fix its.
    package var fixIts: [FixIt] {
        return error.fixIts + additionalFixIts
    }
    
    /// The diagnostic messages.
    package var message: String {
        return error.message
    }
    
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return error.diagnosticID
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return error.severity
    }
}
