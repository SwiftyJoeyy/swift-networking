//
//  ModifiedRequestTests.swift
//  Networking
//
//  Created by Joe Maghzal on 24/05/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.request))
struct ModifiedRequestTests {
    @Test func modifiedRequestID() {
        let base = MockRequest()
        
        do {
            let modifier = MockModifier()
            let request = ModifiedRequest(request: base, modifier: modifier)
            #expect(request.id == base.id)
        }
        
        do {
            let request = ModifiedRequest(request: base) {
                MockModifier()
            }
            #expect(request.id == base.id)
        }
    }
    
    @Test func makeURLRequestAppliesModifier() throws {
        let base = MockRequest()
        let request = ModifiedRequest(request: base) {
            MockModifier()
        }
        
        let result = try request._makeURLRequest()
        
        #expect(result.url?.absoluteString == "https://example.com")
        #expect(result.value(forHTTPHeaderField: "X-Modified") == "true")
    }
    
    @Test func makeURLRequestPreservesBaseRequestValues() throws {
        let base = MockRequest()
        let request = ModifiedRequest(request: base) {
            MockModifier()
        }
        
        let result = try request._makeURLRequest()
        
        #expect(result.httpMethod == "GET")
    }
}

extension ModifiedRequestTests {
    struct MockRequest: Request {
        let method = RequestMethod.get
        
        var request: Never {
            fatalError()
        }
        
        func _makeURLRequest() throws -> URLRequest {
            var request = URLRequest(url: URL(string: "https://example.com")!)
            request.httpMethod = method.rawValue
            return request
        }
    }
    
    @RequestModifier struct MockModifier {
        func modifying(_ request: consuming URLRequest) throws -> URLRequest {
            var modified = request
            modified.setValue("true", forHTTPHeaderField: "X-Modified")
            return modified
        }
    }
}
