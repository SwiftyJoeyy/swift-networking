//
//  ContentType.swift
//
//
//  Created by Joe Maghzal on 5/23/24.
//

import Foundation

public struct ContentType: RequestHeader {
    public let key = "Content-Type"
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(_ type: BodyContentType) {
        self.value = type.value
    }
}

public enum BodyContentType: Equatable, Hashable, Sendable {
    case applicationFormURLEncoded
    case applicationJson
    case multipartFormData(boundary: String)
}

extension BodyContentType {
    public var value: String {
        switch self {
            case .applicationFormURLEncoded:
                return "application/x-www-form-urlencoded"
            case .applicationJson:
                return "application/json"
            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"
        }
    }
}
