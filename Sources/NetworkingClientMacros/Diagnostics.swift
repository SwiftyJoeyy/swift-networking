//
//  SwiftUIView.swift
//  Networking
//
//  Created by Joe Maghzal on 09/06/2025.
//

import SwiftSyntax
import SwiftDiagnostics

internal struct NetworkingFixItMessage: FixItMessage {
    internal var message: String
    
    internal var fixItID: MessageID
    
    internal init(message: String, fixItID: MessageID) {
        self.message = message
        self.fixItID = fixItID
    }
}

extension Diagnostic {
    internal var error: DiagnosticsError {
        return DiagnosticsError(diagnostics: [self])
    }
}

extension Diagnostic {
    internal func fixIt(_ fixIt: (_ diag: Diagnostic) -> FixIt) -> Self {
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
