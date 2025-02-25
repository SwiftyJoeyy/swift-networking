//
//  RequestParameter.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public protocol RequestParameter: RequestModifier {
    var parameters: [URLQueryItem] {get}
}

// MARK: - RequestComponent
extension RequestParameter {
    public func modified(_ request: consuming URLRequest) throws -> URLRequest {
        request.url?.append(queryItems: parameters)
        return request
    }
}
