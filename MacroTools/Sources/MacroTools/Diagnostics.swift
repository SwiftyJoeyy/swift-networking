//
//  Diagnostics.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax
import SwiftDiagnostics

public struct NetworkingFixItMessage: FixItMessage {
    public var message: String
    
    public var fixItID: MessageID
    
    public init(message: String, fixItID: MessageID) {
        self.message = message
        self.fixItID = fixItID
    }
}

extension Diagnostic {
    public var error: DiagnosticsError {
        return DiagnosticsError(diagnostics: [self])
    }
}

extension Diagnostic {
    public func fixIt(_ fixIt: (_ diag: Diagnostic) -> FixIt) -> Self {
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
