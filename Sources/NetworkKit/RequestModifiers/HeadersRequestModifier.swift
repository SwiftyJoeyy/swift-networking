//
//  HeadersRequestModifier.swift
//
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

fileprivate struct HeadersRequestModifier {
    private let headersGroup: HeadersGroup
    
    fileprivate init(_ headersGroup: HeadersGroup) {
        self.headersGroup = headersGroup
    }
}

//MARK: - RequestModifier
extension HeadersRequestModifier: RequestModifier {
    fileprivate func modified(request: URLRequest) throws -> URLRequest {
        return try headersGroup.encoding(into: request)
    }
}

//MARK: - Modifier
extension Request {
    public func additionalHeaders(
        @HeadersBuilder _ headers: () -> [RequestHeadersCollection]
    ) -> some Request {
        modifier(HeadersRequestModifier(HeadersGroup(headers)))
    }
}
