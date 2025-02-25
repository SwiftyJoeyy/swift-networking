//
//  Never+Request.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension Never: Request {
    public var _modifiers: [any RequestModifier] {
        get {
            fatalError("Should not be called directly!!")
        }
        set { }
    }
    
    public var request: Self {
        fatalError("Should not be called directly!!")
    }
}

extension Request where Self.Contents == Never {
    public var request: Never {
        fatalError("Should not be called directly!!")
    }
}
