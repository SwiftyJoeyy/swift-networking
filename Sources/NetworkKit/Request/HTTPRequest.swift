//
//  HTTPRequest.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 1/17/25.
//

import Foundation

public struct HTTPRequest {
    private let url: URL?
    private let path: String?
    
    public var _modifiers = [any RequestModifier]()
    
    public init(
        url: URL? = nil,
        path: String? = nil,
        @RequestModifiersBuilder components: () -> [any RequestModifier] = {[ ]}
    ) {
        self.url = url
        self.path = path
        self._modifiers = components()
    }
    public init(
        url: String,
        path: String? = nil,
        @RequestModifiersBuilder components: () -> [any RequestModifier] = {[ ]}
    ) {
        self.init(
            url: URL(string: url),
            path: path,
            components: components
        )
    }
}

// MARK: - Private Functions
extension HTTPRequest {
    @inline(__always) private func requestURL(baseURL: URL?) -> URL? {
        let url = url ?? baseURL
        guard let path else {
            return url
        }
        return url?.appending(path: path)
    }
}

// MARK: - Request
extension HTTPRequest: Request {
    public typealias Request = Never
    
    public var allModifiers: [any RequestModifier] {
        return _modifiers
    }
    public func _urlRequest(_ baseURL: URL?) throws -> URLRequest {
        guard let url = requestURL(baseURL: baseURL) else {
            throw NKError.invalidRequestURL
        }
        var request = URLRequest(url: url)
        
        for component in _modifiers {
            request = try component.modified(consume request)
        }
        return request
    }
}
