//
//  HeadersRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

@usableFromInline internal struct HeadersRequestModifier {
    private let headers: any RequestHeader
    
    @usableFromInline internal init(_ headers: any RequestHeader) {
        self.headers = headers
    }
}

// MARK: - RequestModifier
extension HeadersRequestModifier: RequestModifier {
    @usableFromInline @inline(__always)
    internal func modified(_ request: consuming URLRequest) throws -> URLRequest {
        return try headers.modified(consume request)
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func additionalHeaders(
        @HeadersBuilder _ headers: () -> HeadersGroup
    ) -> some Request {
        modifier(HeadersRequestModifier(headers()))
    }
}
