//
//  Never+Request.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension Never: @retroactive CustomStringConvertible { }

extension Never: Request {
    /// The request's identifier.
    public var id: String {
        return "Never"
    }
    
    /// Accessing this property will always result in a fatal error.
    ///
    /// - Warning: This should not be accessed directly.
    public var request: Self {
        fatalError("Should not be called directly!!")
    }
}

extension Request where Self.Contents == Never {
    /// Accessing this property will always result in a fatal error.
    ///
    /// - Warning: This should not be accessed directly.
    public var request: Never {
        fatalError("Should not be called directly!!")
    }
    
    public var description: String {
        return """
        \(String(describing: Self.self)) {
          id = \(id)
        }
        """
    }
}
