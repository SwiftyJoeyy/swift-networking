//
//  HTTPMethodRequestModifier.swift
//
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

fileprivate struct HTTPMethodRequestModifier {
    private let httpMethod: RequestMethod
    
    fileprivate init(_ httpMethod: RequestMethod) {
        self.httpMethod = httpMethod
    }
}

//MARK: - RequestModifier
extension HTTPMethodRequestModifier: RequestModifier {
    fileprivate func modified(request: URLRequest) throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.httpMethod = httpMethod.rawValue
        return modifiedRequest
    }
}

//MARK: - Modifier
extension Request {
    public func method(_ httpMethod: RequestMethod) -> some Request {
        modifier(HTTPMethodRequestModifier(httpMethod))
    }
}
