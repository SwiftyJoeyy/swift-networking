//
//  TimeoutRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

@usableFromInline internal struct TimeoutRequestModifier {
    private let timeoutInterval: TimeInterval
    
    @usableFromInline internal init(_ timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
}

// MARK: - RequestModifier
extension TimeoutRequestModifier: RequestModifier {
    @usableFromInline internal func modified(_ request: consuming URLRequest) throws -> URLRequest {
        request.timeoutInterval = timeoutInterval
        return request
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func timeout(_ timeoutInterval: TimeInterval) -> some Request {
        modifier(TimeoutRequestModifier(timeoutInterval))
    }
}
