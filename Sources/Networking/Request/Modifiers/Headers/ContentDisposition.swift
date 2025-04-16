//
//  ContentDisposition.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A `Content-Disposition` header modifier.
@frozen public struct ContentDisposition: RequestHeader, Equatable, Hashable, Sendable {
    /// The header value.
    public let value: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Content-Disposition": value]
    }
    
    /// Creates a new ``ContentDisposition`` modifier.
    ///
    /// - Parameter value: The disposition value.
    @inlinable public init(_ value: String) {
        self.value = value
    }
    
    /// Creates a new ``ContentDisposition`` modifier for form data.
    ///
    /// - Parameters:
    ///  - name: The name of the form field.
    ///  - fileName: The optional file name for the field.
    public init(name: String, fileName: String? = nil) {
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
