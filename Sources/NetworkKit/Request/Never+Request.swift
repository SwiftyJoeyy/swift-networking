//
//  Never+Request.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension Never: Request {
    /// The request's identifier.
    public var id: String {
        return "Never"
    }
    
    /// The request modifiers applied to this request.
    ///
    /// - Warning: This should not be accessed directly.
    public var _modifiers: [any RequestModifier] {
        get {
            fatalError("Should not be called directly!!")
        }
        set { }
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
}
