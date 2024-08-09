//
//  RequestBody.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public protocol RequestBody: RequestComponent {
    var contentType: ContentType {get}
    
    func body() throws -> Data?
}

extension RequestBody {
    public func encoding(into request: URLRequest) throws -> URLRequest {
        var encodedRequest = request
        encodedRequest = try contentType.encoding(into: request)
        encodedRequest.httpBody = try body()
        return encodedRequest
    }
}
