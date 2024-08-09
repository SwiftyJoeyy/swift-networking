//
//  PathRequestModifier.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

fileprivate struct PathRequestModifier {
    private let path: [RequestURLPath]
    private var collapsedPath: RequestURLPath {
        return path.collapsed()
    }
    
    fileprivate init(_ path: [RequestURLPath]) {
        self.path = path
    }
}

//MARK: - RequestModifier
extension PathRequestModifier: RequestModifier {
    fileprivate func modified(request: URLRequest) throws -> URLRequest {
        return try collapsedPath.encoding(into: request)
    }
}

//MARK: - Modifier
extension Request {
    public func appending(paths: [RequestURLPath]) -> some Request {
        modifier(PathRequestModifier(paths))
    }
    
    public func appending(paths: RequestURLPath...) -> some Request {
        appending(paths: paths)
    }
    
    public func appending(
        @PathsBuilder paths: () -> [RequestURLPath]
    ) -> some Request {
        appending(paths: paths())
    }
}
