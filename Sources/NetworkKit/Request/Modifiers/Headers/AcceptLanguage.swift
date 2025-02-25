//
//  AcceptLanguage.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct AcceptLanguage: RequestHeader {
    public var value: String
    
    public var headers: [String: String] {
        return ["Accept-Language": value]
    }
    
    public init(_ value: String) {
        self.value = value
    }
}
