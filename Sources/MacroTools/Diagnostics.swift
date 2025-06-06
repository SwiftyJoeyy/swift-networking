//
//  Diagnostics.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax
import SwiftDiagnostics

package struct NetworkingFixItMessage: FixItMessage {
    package var message: String
    
    package var fixItID: MessageID
    
    package init(message: String, fixItID: MessageID) {
        self.message = message
        self.fixItID = fixItID
    }
}

extension Diagnostic {
    package var error: DiagnosticsError {
        return DiagnosticsError(diagnostics: [self])
    }
}

extension Diagnostic {
    package func fixIt(_ fixIt: (_ diag: Diagnostic) -> FixIt) -> Self {
        return Diagnostic(
            node: node,
            position: position,
            message: diagMessage,
            highlights: highlights,
            notes: notes,
            fixIts: fixIts + [fixIt(self)]
        )
    }
}
