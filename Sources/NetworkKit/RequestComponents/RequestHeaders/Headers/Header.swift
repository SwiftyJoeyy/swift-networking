//
//  Header.swift
//
//
//  Created by Joe Maghzal on 5/23/24.
//

import Foundation

public struct Header: RequestHeader {
    public let key: String
    public let value: String
    
    public init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }
}
