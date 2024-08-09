//
//  RequestURLPath.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

public protocol RequestURLPath: RequestComponent {
    var path: String {get}
}

//MARK: - RequestComponent
extension RequestURLPath {
    public func cleanedPath() -> String {
        let slash = "/"
        var cleaned = path
        if cleaned.hasPrefix(slash) {
            cleaned = String(cleaned.dropFirst())
        }
        if cleaned.hasSuffix(slash) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned
    }
    public func encoding(into request: URLRequest) throws -> URLRequest {
        var encoded = request
        encoded.url?.append(path: cleanedPath())
        return encoded
    }
}

extension String: RequestURLPath {
    public var path: String {
        return self
    }
}

extension Array<RequestURLPath> {
    public func collapsed() -> RequestURLPath {
        let collapsedPath = map(\.path)
        return URLPath(collapsedPath)
    }
}
