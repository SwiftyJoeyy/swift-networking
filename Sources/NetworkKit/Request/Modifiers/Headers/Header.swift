//
//  Header.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public typealias HeadersGroup = Header.Group

public struct Header: RequestHeader {
    public var key: String
    public var value: String
    
    public var headers: [String : String] {
        return [key: value]
    }
    
    public init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension Header {
    public struct Group: RequestHeader {
        public var headers: [String: String]
        
        public init(_ headers: [String: String]) {
            self.headers = headers
        }
        public init(_ headers: [String: String?]) {
            self.init(headers.compactMapValues(\.self))
        }
        public init(_ headers: [any RequestHeader]) {
            self.init(
                headers
                    .reduce(into: [String: String]()) { partialResult, headers in
                        partialResult.merge(headers.headers) { _, new in
                            return new
                        }
                    }
            )
        }
        public init(@HeadersBuilder _ headers: () -> HeadersGroup) {
            self = headers()
        }
    }
}
