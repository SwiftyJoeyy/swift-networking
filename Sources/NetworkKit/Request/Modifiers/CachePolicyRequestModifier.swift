//
//  CachePolicyRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation

// TODO: - Add a way to conditionnally add mods
// TODO: - For sub requests, add a way to use mods builder
// TODO: - Check if we make the builder only for httpBODY
@usableFromInline internal struct CachePolicyRequestModifier {
    private let cachePolicy: URLRequest.CachePolicy
    
    @usableFromInline internal init(_ cachePolicy:  URLRequest.CachePolicy) {
        self.cachePolicy = cachePolicy
    }
}

// MARK: - RequestModifier
extension CachePolicyRequestModifier: RequestModifier {
    @usableFromInline internal func modified(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        request.cachePolicy = cachePolicy
        return request
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> some Request {
        modifier(CachePolicyRequestModifier(cachePolicy))
    }
}
