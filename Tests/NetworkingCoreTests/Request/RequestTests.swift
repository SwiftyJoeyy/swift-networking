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
    private let configurations = ConfigurationValues.mock
    private let url = URL(string: "example.com")!
    
    @Test func buildsURLRequest() throws {
        
    }
    
    @Test func requestIDAppliedFromMacro() throws {
        let request = MacrosRequest()
        
        #expect(request.id == "SomeID")
    }
    
    @Test func requestWithoutID() throws {
        let request = NestedRequest()
        
        #expect(request.id == "NestedRequest")
    }
    
    @Test func requestWithExplicitID() throws {
        let id = "testing"
        let request = DummyRequest(id: id)
        
        #expect(request.id == id)
    }
}

extension Tag {
    @Tag internal static var request: Self
}
