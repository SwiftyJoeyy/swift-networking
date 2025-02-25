//
//  Request.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

public protocol Request: _Request {
    associatedtype Contents: Request
    
    var id: String? {get}
    var request: Self.Contents {get}
    var allModifiers: [any RequestModifier] {get}
}

// MARK: - _Request
extension Request {
    public var id: String? {
        return nil
    }
    public func _urlRequest(_ baseURL: URL?) throws -> URLRequest {
        var configuredRequest = request
        configuredRequest._modifiers.append(contentsOf: _modifiers)
        return try configuredRequest._urlRequest(baseURL)
    }
    
    public var allModifiers: [any RequestModifier] {
        return _modifiers + request.allModifiers
    }
}
