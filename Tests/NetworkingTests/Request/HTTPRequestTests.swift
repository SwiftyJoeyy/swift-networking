//
//  HTTPRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import Testing
@testable import Networking

@Suite(.tags(.request))
struct HTTPRequestTests {
    private let configuration = ConfigurationValues.mock
    
    @Test func initWithStringURLOnly() throws {
        let request = HTTPRequest(url: "https://example.com")
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func initWithStringURLAndPath() throws {
        let request = HTTPRequest(url: "https://example.com", path: "test")
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/test")
    }
    
    @Test func initWithURLOnly() throws {
        let request = HTTPRequest(url: URL(string: "https://example.com"))
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func initWithURLAndPath() throws {
        let request = HTTPRequest(url: URL(string: "https://example.com"), path: "test")
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/test")
    }
    
    @Test func nestedRequestModifierIsApplied() throws {
        let request = HTTPRequest(url: "https://example.com") {
            DummyModifier(header: ("Content-Type", "application/json"))
        }
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
    
    @Test func allModifiersIncludesNestedRequestModifiers() {
        let request = HTTPRequest {
            RequestModifierStub()
        }.modifier(RequestModifierStub())
        
        #expect(request.allModifiers.filter({$0 is RequestModifierStub}).count == 2)
    }
    
    @Test func allRequestModifiersAreApplied() throws {
        let request = HTTPRequest(url: "https://example.com") {
            DummyModifier(header: ("Content-Type", "application/json"))
        }.modifier(DummyModifier(header: ("Language", "en")))
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Language") == "en")
    }
    
    @Test func throwsWhenURLMissing() {
        let request = HTTPRequest()
        var configuration = ConfigurationValues.mock
        configuration.baseURL = nil
        
        #expect(throws: NKError.invalidRequestURL) {
            _ = try request._makeURLRequest(configuration)
        }
    }
    
    @Test func baseURLFromConfiguration() throws {
        var configuration = ConfigurationValues.mock
        configuration.baseURL = URL(string: "https://fallback.com")
        let request = HTTPRequest()
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        assert(urlRequest.url?.absoluteString == "https://fallback.com")
    }
    
    @Test func baseURLFromConfigurationWithPath() throws {
        var configuration = ConfigurationValues.mock
        configuration.baseURL = URL(string: "https://fallback.com")
        let request = HTTPRequest(path: "test")
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        assert(urlRequest.url?.absoluteString == "https://fallback.com/test")
    }
}

extension HTTPRequestTests {
    struct DummyModifier: RequestModifier {
        let header: (String, String)
        func modifying(
            _ request: consuming URLRequest,
            with config: borrowing ConfigurationValues
        ) throws -> URLRequest {
            request.setValue(header.1, forHTTPHeaderField: header.0)
            return request
        }
    }
}
