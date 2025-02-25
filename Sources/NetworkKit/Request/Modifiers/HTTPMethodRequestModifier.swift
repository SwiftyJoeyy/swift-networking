//
//  HTTPMethodRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

@usableFromInline internal struct HTTPMethodRequestModifier {
    private let httpMethod: RequestMethod
    
    @usableFromInline internal init(_ httpMethod: RequestMethod) {
        self.httpMethod = httpMethod
    }
}

// MARK: - RequestModifier
extension HTTPMethodRequestModifier: RequestModifier {
    @usableFromInline internal func modified(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        request.httpMethod = httpMethod.rawValue
        return request
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func method(_ httpMethod: RequestMethod) -> some Request {
        modifier(HTTPMethodRequestModifier(httpMethod))
    }
}
