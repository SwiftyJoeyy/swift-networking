//
//  ContentDisposition.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public struct ContentDisposition: RequestHeader {
    public let key = "Content-Disposition"
    public let value: String
    
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
        self.value = disposition
    }
}
