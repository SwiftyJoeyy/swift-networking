//
//  HeadersGroup.swift
//
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

public struct HeadersGroup: RequestHeadersCollection {
    public let headers: [String: String]
    
    public init(@HeadersBuilder _ headers: () -> [RequestHeadersCollection]) {
        self.headers = headers()
            .reduce(into: [String: String]()) { partialResult, headers in
                partialResult.merge(headers.headers) { current, new in
                    return new
                }
            }
    }
}
