//
//  RequestHeader.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public protocol RequestHeader: RequestModifier {
    var headers: [String: String] {get}
}

// MARK: - RequestComponent
extension RequestHeader {
    public func modified(_ request: consuming URLRequest) throws -> URLRequest {
        let requestHeaders = request.allHTTPHeaderFields ?? [:]
        request.allHTTPHeaderFields = requestHeaders.merging(headers) { current, new in
            return new
        }
        return request
    }
}
