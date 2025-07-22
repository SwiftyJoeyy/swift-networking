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
// MARK: - Properties
    private let configurations = ConfigurationValues()
    private let url = URL(string: "https://example.com")
    
// MARK: - Initializers Tests
    @Test func initWithStringURLOnly() throws {
        let request = HTTPRequest(url: url!.absoluteString)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func initWithStringURLAndPath() throws {
        let request = HTTPRequest(url: url!.absoluteString, path: "test")
        
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
    
// MARK: - Make URLRequest Tests
    @Test func makeURLRequestSetsupModifier() throws {
        let value = UUID().uuidString
        var configurations = ConfigurationValues()
        configurations[MockConfigKey.self] = value
        
        let request = HTTPRequest(url: url) {
            ConfiguredModifier()
        }
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        let headerValue = try #require(urlRequest.value(forHTTPHeaderField: "ConfigHeader"))
        #expect(headerValue == value)
    }
    @Test func requestWithModifiers() throws {
        let request = HTTPRequest(url: url) {
            DummyModifier(header: ("test", "value"))
        }
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.allHTTPHeaderFields?["test"] == "value")
    }
    
    @Test func throwsErrorWhenURLIsMissing() throws {
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
    
    @Test func throwsWhenWhenAnyModifierRemovesURL() throws {
        let request = HTTPRequest(url: url) {
            EmptyURLModifier()
        }
        
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
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://fallback.com")
    }
    
    @Test func requestURLOverridesConfigurationsURL() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://fallback.com")
        
        let request = HTTPRequest(url: url)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
    
    @Test func baseURLFromConfigurationWithPath() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://fallback.com")
        
        let request = HTTPRequest(path: "test")
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.url?.absoluteString == "https://fallback.com/test")
    }
    
    @Test func removesHTTPBodyForGETRequests() throws {
        let request = HTTPRequest(url: url) {
            BodyModifier()
        }
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        
        #expect(urlRequest.httpBody == nil)
    }
}

extension HTTPRequestTests {
    @RequestModifier struct DummyModifier {
        let header: (String, String)
        func modifying(
            _ request: consuming URLRequest
        ) throws(NetworkingError) -> URLRequest {
            request.setValue(header.1, forHTTPHeaderField: header.0)
            return request
        }
    }
    
    @RequestModifier struct BodyModifier {
        func modifying(
            _ request: consuming URLRequest
        ) throws(NetworkingError) -> URLRequest {
            request.httpBody = "test".data(using: .utf8)
            request.httpMethod = RequestMethod.get.rawValue
            return request
        }
    }
    
    @RequestModifier struct EmptyURLModifier {
        func modifying(
            _ request: consuming URLRequest
        ) throws(NetworkingError) -> URLRequest {
            request.url = nil
            return request
        }
    }
}
