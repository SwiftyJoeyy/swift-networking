//
//  URLPath.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

public struct URLPath: RequestURLPath {
    public let path: String
    
    @inlinable
    public init(_ path: String) {
        self.path = path
    }
    
    @inlinable
    public init(_ paths: [String]) {
        self.init(paths.joined(separator: "/"))
    }
    
    @inlinable
    public init(_ paths: String...) {
        self.init(paths)
    }
}
