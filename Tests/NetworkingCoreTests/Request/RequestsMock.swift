//
//  RequestsMock.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
@testable import NetworkingCore

struct DummyRequest: Request {
    typealias Contents = Never
}

struct MockRequest: Request {
    struct Contents: Request {
        typealias Contents = Never
        let id = "NestedRequest"
        
        func _makeURLRequest(
            _ configurations: borrowing ConfigurationValues
        ) throws -> URLRequest {
            var request = URLRequest(url: URL(string: "https://example.com")!)
            request.httpMethod = "GET"
            return request
        }
    }
    
    var request = Contents()
}
