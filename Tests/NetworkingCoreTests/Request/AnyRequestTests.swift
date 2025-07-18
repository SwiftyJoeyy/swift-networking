//
//  AnyRequestTests.swift
//  Networking
//
//  Created by Joe Maghzal on 24/05/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.request))
struct AnyRequestTests {
    @Test func anyRequestStoresRequestID() {
        let id = "mock-id"
        let request = MockRequest(id: id, path: "", method: .get)
        let erased = AnyRequest(request)
        #expect(erased.id == id)
    }
    
    @Test func anyRequestBuildsCorrectURLRequest() throws {
        let request = MockRequest(id: "mock-id", path: "/mock", method: .post)
        let erased = AnyRequest(request)
        
        let urlRequest = try erased._makeURLRequest(with: ConfigurationValues())
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/mock")
        #expect(urlRequest.httpMethod == "POST")
    }
}

extension AnyRequestTests {
    struct MockRequest: Request {
        let id: String
        let path: String
        let method: RequestMethod
        
        var request: Never {
            fatalError()
        }
        
        func _makeURLRequest(
            with configurations: ConfigurationValues
        ) throws(NetworkingError) -> URLRequest {
            var request = URLRequest(url: URL(string: "https://example.com\(path)")!)
            request.httpMethod = method.rawValue
            return request
        }
    }
}
