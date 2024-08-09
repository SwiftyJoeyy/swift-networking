//
//  MacroErrorFixItMessage.swift
//
//
//  Created by Joe Maghzal on 06/05/2024.
//

import Foundation
import SwiftDiagnostics

/// A message for fix-its associated with macro errors.
package struct MacroErrorFixItMessage: FixItMessage {
    /// The fix it messages.
    package let message: String
    
    /// The unique identifier for the fix it.
    package let fixItID: MessageID
}

//MARK: - Initializer
extension MacroErrorFixItMessage {
    /// Creates a fix it message with the provided message and ID.
    ///
    /// - Parameters:
    ///   - message: The fix it message.
    ///   - id: The unique identifier for the fix it.
    package init(message: String, id: String) {
        self.message = message
        self.fixItID = MessageID(domain: "ElementaryUIMacros", id: id)
    }
}
