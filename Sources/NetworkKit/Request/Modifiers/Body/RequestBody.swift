//
//  RequestBody.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public protocol RequestBody: RequestModifier {
    var contentType: ContentType? {get}
    
    func body() throws -> Data?
}

extension RequestBody {
    public func modified(_ request: consuming URLRequest) throws -> URLRequest {
        if let contentType {
            request = try contentType.modified(consume request)
        }
        request.httpBody = try body()
        return request
    }
}
