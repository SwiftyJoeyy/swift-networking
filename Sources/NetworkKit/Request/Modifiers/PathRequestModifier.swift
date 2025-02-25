//
//  PathRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

@usableFromInline internal struct PathRequestModifier<S: StringProtocol> {
    private let paths: [S]
    
    @usableFromInline internal init(_ paths: [S]) {
        self.paths = paths
    }
}

// MARK: - RequestModifier
extension PathRequestModifier: RequestModifier {
    @usableFromInline internal func modified(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        for path in paths {
            request.url?.append(path: path)
        }
        return request
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func appending(paths: [some StringProtocol]) -> some Request {
        modifier(PathRequestModifier(paths))
    }
    
    @inlinable public func appending<S: StringProtocol>(paths: S...) -> some Request {
        appending(paths: paths)
    }
}
