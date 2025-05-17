//
//  HTTPRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

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
        let request = HTTPRequest(
            url: URL(string: "https://example.com"),
            path: "test"
        )
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/test")
    }
    
    @Test func requestWithModifiers() throws {
        let request = HTTPRequest(
            url: URL(string: "https://example.com")
        ) {
            DummyModifier(header: ("test", "value"))
        }
        
        let urlRequest = try request._makeURLRequest(configuration)
        
        #expect(urlRequest.allHTTPHeaderFields?["test"] == "value")
    }
    
    @Test func throwsWhenURLMissing() {
        let request = HTTPRequest()
        var configuration = ConfigurationValues.mock
        configuration.baseURL = nil
        
        #expect(throws: NetworkingError.invalidRequestURL) {
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
