//
//  Parameter.swift
//
//
//  Created by Joe Maghzal on 5/28/24.
//

import Foundation

public struct Parameter: RequestParameter {
    public var key: String
    public var value: [String?]
    
    public init(_ key: String, value: [String?]) {
        self.key = key
        self.value = value
    }
    
    public init(_ key: String, value: String?) {
        self.key = key
        self.value = [value]
    }
}
