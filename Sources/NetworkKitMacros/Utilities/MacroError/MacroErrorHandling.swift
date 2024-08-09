//
//  MacroErrorHandling.swift
//  
//
//  Created by Joe Maghzal on 06/05/2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntax

/// Executes the provided closure, catches any `MacroError`, and reports the error as diagnostic messages with its associated fix its.
///
/// - Parameters:
///   - context: The macro expansion context.
///   - node: The syntax node associated with the error.
///   - body: The closure to execute.
///
/// - Returns: The result of the closure.
///
/// - Throws: Any error thrown by the closure.
package func withErroHandling<T>(
    context: some MacroExpansionContext,
    node: SyntaxProtocol, 
    onFailure: T? = nil,
    _ body: () throws -> T
) throws -> T {
    do {
        return try body()
    }catch let error as MacroError {
        let diagnostic = Diagnostic(node: node, message: error, fixIts: error.fixIts)
        context.diagnose(diagnostic)
        if let onFailure {
            return onFailure
        }
        throw error
    }catch {
        if let onFailure {
            return onFailure
        }
        throw error
    }
}
