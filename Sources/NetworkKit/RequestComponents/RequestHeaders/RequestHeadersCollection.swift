//
//  RequestHeadersCollection.swift
//
//
//  Created by Joe Maghzal on 5/23/24.
//

import Foundation

public protocol RequestHeadersCollection: RequestComponent {
    var headers: [String: String] {get}
}

//MARK: - RequestComponent
extension RequestHeadersCollection {
    public func encoding(into request: URLRequest) throws -> URLRequest {
        var newRequest = request
        let requestHeaders = newRequest.allHTTPHeaderFields ?? [:]
        newRequest.allHTTPHeaderFields = requestHeaders.merging(headers) { current, new in
            return new
        }
        return newRequest
    }
}
