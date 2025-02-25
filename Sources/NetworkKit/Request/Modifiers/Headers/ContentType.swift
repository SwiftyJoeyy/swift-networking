//
//  ContentType.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct ContentType: RequestHeader {
    public var type: BodyContentType
    
    public var headers: [String: String] {
        return ["Content-Type": type.value]
    }
    
    public init(_ type: BodyContentType) {
        self.type = type
    }
}

public enum BodyContentType: Equatable, Hashable, Sendable {
    case applicationFormURLEncoded
    case applicationJson
    case multipartFormData(boundary: String)
    case custom(String)

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
