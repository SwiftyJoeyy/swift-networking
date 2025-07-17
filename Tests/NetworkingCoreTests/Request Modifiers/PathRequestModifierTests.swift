//
//  PathRequestModifierTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@_spi(Internal) @testable import NetworkingCore

@Suite(.tags(.requestModifiers, .path))
struct PathRequestModifierTests {
    private let configurations: ConfigurationValues = {
        var values = ConfigurationValues()
        values.baseURL = URL(string: "https://example.com")
        return values
    }()
    
    @Test func appendingSinglePathComponent() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test"])
        
        request = try modifier.modifying(request)
        let paths = try #require(request.url?.pathComponents)
        #expect(paths.contains("test"))
    }
    
    @Test func appendingMultiplePathComponents() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test", "path", "123"])
        
        request = try modifier.modifying(request)
        let paths = try #require(request.url?.pathComponents)
        #expect(paths.contains("test"))
        #expect(paths.contains("path"))
        #expect(paths.contains("123"))
    }
    
    @Test func appendingPathComponentToExistingPath() throws {
        var request = URLRequest(url: URL(string: "https://example.com/base")!)
        let modifier = PathRequestModifier(["additional"])
        
        request = try modifier.modifying(request)
        let paths = try #require(request.url?.pathComponents)
        #expect(paths.contains("base"))
        #expect(paths.contains("additional"))
    }
    
    @Test func appendingEmptyPathDoesNotChangeURL() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier([""])
        
        request = try modifier.modifying(request)
        let paths = try #require(request.url?.pathComponents)
        #expect(paths.isEmpty)
    }
}

// MARK: - Description Tests
extension PathRequestModifierTests {
    @Test func descriptionWithEmptyPaths() {
        let modifier = PathRequestModifier([])
        let result = modifier.description
        
        #expect(result.contains("paths = []"))
    }
    @Test func descriptionIncludesAllPaths() {
        let modifier = PathRequestModifier(["users", "123", "profile"])
        let result = modifier.description
        
        #expect(result.contains("paths = [\"users\", \"123\", \"profile\"]"))
    }
}

// MARK: - Modifier Tests
extension PathRequestModifierTests {
    @Test func appliesPathModifierWithStringComponentsToRequest() throws {
        do {
            let request = HTTPRequest()
                .appending("somePath")
            
            let urlRequest = try request._makeURLRequest(with: configurations)
            let paths = try #require(urlRequest.url?.pathComponents)
            #expect(paths.contains("somePath"))
        }
        
        do {
            let request = HTTPRequest()
                .appending("somePath", "v2")
            
            let urlRequest = try request._makeURLRequest(with: configurations)
            let paths = try #require(urlRequest.url?.pathComponents)
            #expect(paths.contains("somePath"))
            #expect(paths.contains("v2"))
        }
    }
    
    @Test func appliesPathModifierWithStringConvertableComponentsToRequest() throws {
        let request = HTTPRequest()
            .appending(1, true, 5.6)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        let paths = try #require(urlRequest.url?.pathComponents)
        #expect(paths.contains("1"))
        #expect(paths.contains("true"))
        #expect(paths.contains("5.6"))
    }
    
    @Test func appliesPathModifierWithOptionalComponentsHoldingNilValuesToRequest() throws {
        do {
            let path: String? = nil
            let request = HTTPRequest()
                .appending(path)
            
            let urlRequest = try request._makeURLRequest(with: configurations)
            let paths = try #require(urlRequest.url?.pathComponents)
            #expect(!paths.contains("1"))
        }
        
        do {
            let path: Bool? = nil
            let request = HTTPRequest()
                .appending(1, path)
            
            let urlRequest = try request._makeURLRequest(with: configurations)
            let paths = try #require(urlRequest.url?.pathComponents)
            #expect(paths.contains("1"))
            #expect(!paths.contains("true"))
        }
    }
}

extension Tag {
    @Tag internal static var path: Self
}
