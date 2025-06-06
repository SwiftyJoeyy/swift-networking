//
//  RequestsMock.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
@testable import NetworkingCore

struct DummyRequest: Request {
    var request: Never {
        fatalError()
    }
}

struct MockRequest: Request {
    struct Contents: Request {
        let id = "NestedRequest"
        
        var request: Never {
            fatalError()
        }
        
        func _makeURLRequest() throws -> URLRequest {
            var request = URLRequest(url: URL(string: "https://example.com")!)
            request.httpMethod = "GET"
            return request
        }
    }
    
    var request = Contents()
}
