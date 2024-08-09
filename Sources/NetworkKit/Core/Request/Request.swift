//
//  Request.swift
//  
//
//  Created by Joe Maghzal on 29/05/2024.
//

import Foundation

public protocol Request: _Request {
    associatedtype Contents: Request
    var request: Self.Contents {get}
}

//MARK: - _Request
extension Request {
    public func _urlRequest(_ baseURL: URL?) throws -> URLRequest {
        var configuredRequest = request
        configuredRequest.modifiers.append(contentsOf: modifiers)
        return try configuredRequest._urlRequest(baseURL)
    }
}

//MARK: - _ModifyableRequest
extension Request {
    public var modifiers: [RequestModifier] {
        get {
            return []
        }
        set { }
    }
}
