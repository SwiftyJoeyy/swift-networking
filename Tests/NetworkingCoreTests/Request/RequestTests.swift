//
//  RequestTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.request))
struct RequestTests {
    @Test func buildsURLRequest() throws {
        let request = MockRequest()
        let urlRequest = try request._makeURLRequest()
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
        #expect(urlRequest.httpMethod == "GET")
    }
    
    @Test func requestWithoutID() throws {
        let request = MockRequest()
        
        #expect(request.id == "MockRequest")
    }
    
    @Test func descriptionIncludesIDAndNestedRequest() {
        let request = MockRequest()
        let description = request.description
        #expect(description.contains("MockRequest"))
        #expect(description.contains("NestedRequest"))
    }

}

extension Tag {
    @Tag internal static var request: Self
}
