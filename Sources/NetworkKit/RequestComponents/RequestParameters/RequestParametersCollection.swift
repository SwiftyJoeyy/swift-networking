//
//  RequestParametersCollection.swift
//  
//
//  Created by Joe Maghzal on 5/28/24.
//

import Foundation

public protocol RequestParametersCollection: RequestComponent {
    var parameters: [URLQueryItem] {get}
}

//MARK: - RequestComponent
extension RequestParametersCollection {
    public func encoding(into request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.url?.append(queryItems: parameters)
        return modifiedRequest
    }
}
