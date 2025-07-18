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
    private let configurations = ConfigurationValues()
    private let url = URL(string: "https://example.com")
    
    @Test func initWithStringURLOnly() throws {
        let request = HTTPRequest(url: url)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func initWithStringURLAndPath() throws {
        let request = HTTPRequest(url: url, path: "test")
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/test")
    }
    
    @Test func initWithURLOnly() throws {
        let request = HTTPRequest(url: url)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func initWithURLAndPath() throws {
        let request = HTTPRequest(url: url, path: "test")
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com/test")
    }
    
    @Test func requestWithModifiers() throws {
        let request = HTTPRequest(url: url) {
            DummyModifier(header: ("test", "value"))
        }
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.allHTTPHeaderFields?["test"] == "value")
    }
    
    @Test func throwsWhenURLMissing() throws {
        let request = HTTPRequest()
        
        let networkingError = try #require(throws: NetworkingError.self) {
            _ = try request._makeURLRequest(with: configurations)
        }
        var foundCorrectError = false
        if case NetworkingError.invalidRequestURL = networkingError {
            foundCorrectError = true
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
    }
    
    @Test func baseURLFromConfiguration() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://fallback.com")
        
        let request = HTTPRequest()
        request._accept(configurations)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        assert(urlRequest.url?.absoluteString == "https://fallback.com")
    }
    
    @Test func baseURLFromConfigurationWithPath() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://fallback.com")
        
        let request = HTTPRequest(path: "test")
        request._accept(configurations)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        assert(urlRequest.url?.absoluteString == "https://fallback.com/test")
    }
}

extension HTTPRequestTests {
    @RequestModifier struct DummyModifier {
        let header: (String, String)
        func modifying(_ request: consuming URLRequest) throws(NetworkingError) -> URLRequest {
            request.setValue(header.1, forHTTPHeaderField: header.0)
            return request
        }
    }
}
