//
//  Never+Request.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension Swift.Never: Swift.CustomStringConvertible { }

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
    
    /// Calling this method will always result in a fatal error.
    ///
    /// - Warning: This should not be accessed directly.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        fatalError("Should not be called directly!!")
    }
}

extension Request where Contents == Never {
    public var description: String {
        return """
        \(String(describing: Self.self)) {
          id = \(id)
        }
        """
    }
    
    public func _accept(_ values: ConfigurationValues) { }
}
