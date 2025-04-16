//
//  ContentType.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A `Content-Type` header modifier.
@frozen public struct ContentType: RequestHeader, Equatable, Hashable, Sendable {
    /// The content type.
    public var type: BodyContentType
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Content-Type": type.value]
    }
    
    /// Creates a new ``ContentType`` modifier.
    ///
    /// - Parameter type: The content type to apply.
    @inlinable public init(_ type: BodyContentType) {
        self.type = type
    }
}

/// The standard HTTP content types.
@frozen public enum BodyContentType: Equatable, Hashable, Sendable {
    /// `application/x-www-form-urlencoded`.
    case applicationFormURLEncoded
    
    /// `application/json`.
    case applicationJson
    
    /// `multipart/form-data` with a boundary string.
    ///
    /// - Parameter boundary: The boundary string used for separating parts.
    case multipartFormData(boundary: String)
    
    /// Custom content type.
    case custom(String)

    /// The corresponding string value of the content type.
    public var value: String {
        switch self {
            case .applicationFormURLEncoded:
                return "application/x-www-form-urlencoded"
            case .applicationJson:
                return "application/json"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            case .custom(let type):
                return type
        }
    }
}
