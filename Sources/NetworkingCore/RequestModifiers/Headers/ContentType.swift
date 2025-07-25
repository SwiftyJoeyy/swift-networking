//
//  ContentType.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// A `Content-Type` header modifier.
@frozen public struct ContentType: RequestHeader, Equatable, Hashable, Sendable {
    /// The content type.
    public var type: String
    
    /// The headers dictionary representation.
    public var headers: [String: String] {
        return ["Content-Type": type]
    }
    
    /// Creates a new ``ContentType`` modifier.
    ///
    /// - Parameter type: The content type to apply.
    @inlinable public init(_ type: String) {
        self.type = type
    }
    
    /// Creates a new ``ContentType`` modifier.
    ///
    /// - Parameter type: The content type to apply.
    @inlinable public init(_ type: BodyContentType) {
        self.init(type.value)
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
    
    /// `text/plain`.
    case text
    
    /// `text/html`.
    case html
    
    /// `application/xml`.
    case applicationXML
    
    /// `*/*`.
    case any
    
#if canImport(UniformTypeIdentifiers)
    /// Mime Type
    case mime(UTType)
#endif

    /// The corresponding string value of the content type.
    public var value: String {
        switch self {
            case .applicationFormURLEncoded:
                return "application/x-www-form-urlencoded"
            case .applicationJson:
                return "application/json"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
            case .text:
                return "text/plain"
            case .html:
                return "text/html"
            case .applicationXML:
                return "application/xml"
            case .any:
                return "*/*"
#if canImport(UniformTypeIdentifiers)
            case .mime(let type):
                return type.preferredMIMEType ?? "Unsupported"
#endif
        }
    }
}
