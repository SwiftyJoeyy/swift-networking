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
    
// MARK: - Make URLRequest Tests
    @Test func buildsURLRequest() throws {
        let request = MockRequest()
        let urlRequest = try request._makeURLRequest(with: ConfigurationValues())
        
        #expect(urlRequest.url?.absoluteString == "https://example.com")
        #expect(urlRequest.httpMethod == "GET")
    }
    
    @Test func makeURLRequestUsesPassedConfigurations() throws {
        let value = UUID().uuidString
        var configurations = ConfigurationValues()
        configurations[MockConfigKey.self] = value
        
        let request = MockRequest()
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        let headerValue = try #require(urlRequest.value(forHTTPHeaderField: "ConfigHeader"))
        #expect(headerValue == value)
    }
    
    @Test func makeURLRequestSetsUpRequestConfigurations() throws {
        let value = UUID().uuidString
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://example.com")
        configurations[MockConfigKey.self] = value
        
        let request = ConfiguredRequest()
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        let headerValue = try #require(urlRequest.value(forHTTPHeaderField: "ConfigHeader"))
        #expect(headerValue == value)
    }
    
    @Test func makeURLRequestAddsHeadersAndParametersFromMacro() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://example.com")
        
        let expectedHeaderValue = UUID().uuidString
        let expectedParamValue = Int.random(in: 0..<10000)
        let request = ConfiguredRequest(macroHeader: expectedHeaderValue, macroParam: expectedParamValue)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        let headerValue = try #require(urlRequest.value(forHTTPHeaderField: "macroHeader"))
        
        #expect(headerValue == expectedHeaderValue)
        #expect(urlRequest.url?.absoluteString == "https://example.com?macroParam=\(expectedParamValue)")
    }
    
    @Test func makeURLRequestDoesNotAddNilHeadersAndParametersFromMacro() throws {
        var configurations = ConfigurationValues()
        configurations.baseURL = URL(string: "https://example.com")
        
        let request = ConfiguredRequest()
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        #expect(urlRequest.value(forHTTPHeaderField: "macroHeader") == nil)
        #expect(urlRequest.url?.absoluteString == "https://example.com")
    }
}

extension RequestTests {
    @Request struct ConfiguredRequest {
        @Configurations private var configurations
        @Header var macroHeader: String?
        @Parameter var macroParam: Int?
        var request: some Request {
            HTTPRequest()
                .additionalHeader("ConfigHeader", value: configurations[MockConfigKey.self])
        }
    }
}

extension Tag {
    @Tag internal static var request: Self
}
