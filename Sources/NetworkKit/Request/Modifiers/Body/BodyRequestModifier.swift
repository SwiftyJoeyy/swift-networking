//
//  BodyRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/21/25.
//

import Foundation

// TODO: Check if modifiers contains same modifier
@usableFromInline internal struct BodyRequestModifier {
    public let id: String? = "Body"
    private let body: any RequestBody
    
    @usableFromInline internal init(_ body: any RequestBody) {
        self.body = body
    }
}

// MARK: - RequestModifier
extension BodyRequestModifier: RequestModifier {
    @usableFromInline @inline(__always)
    internal func modified(_ request: consuming URLRequest) throws -> URLRequest {
        return try body.modified(consume request)
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func body(_ body: () -> any RequestBody) -> some Request {
        modifier(BodyRequestModifier(body()))
    }
}
