//
//  AcceptLanguage.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// An `Accept-Language` header modifier.
@frozen public struct AcceptLanguage: RequestHeader {
    /// The language value.
    public var value: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Accept-Language": value]
    }
    
    /// Creates a new ``AcceptLanguage`` modifier.
    ///
    /// - Parameter value: The language value to apply.
    public init(_ value: String) {
        self.value = value
    }
}
