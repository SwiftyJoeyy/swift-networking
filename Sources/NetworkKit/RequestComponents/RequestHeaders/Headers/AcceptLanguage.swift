//
//  AcceptLanguage.swift
//
//
//  Created by Joe Maghzal on 5/23/24.
//

import Foundation

public struct AcceptLanguage: RequestHeader {
    public let key = "Accept-Language"
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
}
