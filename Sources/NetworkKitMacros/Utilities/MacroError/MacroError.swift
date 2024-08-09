//
//  MacroError.swift
//  
//
//  Created by Joe Maghzal on 06/05/2024.
//

import Foundation
import SwiftDiagnostics

/// Requirements for defining a macro error that provides diagnostic messages and fix-it suggestions.
///
///```swift
/// enum SomeMacroError: MacroError {
///     case someError
///     var message: String {
///         switch self {
///             case .someError:
///                 return "Some error message..."
///         }
///     }
/// }
/// ```
package protocol MacroError: Error, DiagnosticMessage {
    /// The fix-its associated with the error.
    var fixIts: [FixIt] {get}
}

//MARK: - Default Implementations
extension MacroError {
    /// The unique identifier for the diagnostic message.
    package var diagnosticID: MessageID {
        return MessageID(domain: "ElementaryUIMacros", id: "\(self)")
    }
    
    /// The severity level of the diagnostic message.
    package var severity: DiagnosticSeverity {
        return .error
    }
    
    /// Default implementation of `fixIts`.
    package var fixIts: [FixIt] {
        return []
    }
}

//MARK: - Modifiers
extension MacroError {
    /// Adds additional fix its to the error.
    /// Use this modifier to add additional fix its to the error.
    ///
    /// - Parameter fixIts: An array of fix its associated with the error.
    /// - Returns: A ``MacroErrorFixItWrapper`` containing the error and the provided fix its.
    package func withFixIts(_ fixIts: [FixIt]) -> MacroErrorFixItWrapper {
        return MacroErrorFixItWrapper(error: self, fixIts: fixIts)
    }
    
    /// Adds an additional fix it to the error.
    /// Use this modifier to add an additional fix it to the error.
    ///
    /// - Parameter fixIt: A fix it associated with the error.
    /// - Returns: A ``MacroErrorFixItWrapper`` containing the error and the provided fix it.
    package func withFixIt(_ fixIt: FixIt) -> MacroErrorFixItWrapper {
        withFixIts([fixIt])
    }
}
