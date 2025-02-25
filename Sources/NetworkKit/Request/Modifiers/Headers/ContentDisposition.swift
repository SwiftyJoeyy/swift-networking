//
//  ContentDisposition.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct ContentDisposition: RequestHeader {
    public let value: String
    
    public var headers: [String: String] {
        return ["Content-Disposition": value]
    }
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(_ name: String, fileName: String? = nil) {
        var disposition = """
        form-data; name="\(name)"
        """
        if let fileName {
            disposition += """
            ; filename="\(fileName)"
            """
        }
        self.init(disposition)
    }
}
