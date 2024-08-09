//
//  HTTPRequest.swift
//  
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

public struct HTTPRequest {
    private let url: URL?
    private let path: String?
    
    public var modifiers = [RequestModifier]()
    
    public init(
        url: URL? = nil,
        path: String? = nil,
        @RequestComponentsBuilder components: () -> [RequestComponent]
    ) {
        self.url = url
        self.path = path
        self.modifiers = components()
    }
}

//MARK: - Private Functions
extension HTTPRequest {
    @inline(__always)
    private func requestURL(baseURL: URL?) -> URL? {
        let url = url ?? baseURL
        if let path {
            return url.flatMap({URL(string: path, relativeTo: $0)})
        }
        return url
    }
}

//MARK: - Request
extension HTTPRequest: Request {
    public var request: Never._Request {
        fatalError("Should not be called directly!!")
    }
    
    public func _urlRequest(_ baseURL: URL?) throws -> URLRequest {
        guard let url = requestURL(baseURL: baseURL) else {
            throw NKError.invalidRequestURL
        }
        var request = URLRequest(url: url)
        
        for component in modifiers {
            request = try component.modified(request: request)
        }
        return request
    }
}
