//
//  URLPathTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Suite(.tags(.requestModifiers, .path))
struct PathRequestModifierTests {
    private let configurations = ConfigurationValues.mock
    
    @Test func appendingSinglePathComponent() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test"])
        
        request = try modifier.modifying(request, with: configurations)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/test")
    }
    
    @Test func appendingMultiplePathComponents() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test", "path", "123"])
        
        request = try modifier.modifying(request, with: configurations)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/test/path/123")
    }
    
    @Test func appendingPathComponentToExistingPath() throws {
        var request = URLRequest(url: URL(string: "https://example.com/base")!)
        let modifier = PathRequestModifier(["additional"])
        
        request = try modifier.modifying(request, with: configurations)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/base/additional")
    }
    
    @Test func appendingEmptyPathDoesNotChangeURL() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier([""])
        
        request = try modifier.modifying(request, with: configurations)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/")
    }
}

// MARK: - Modifier Tests
extension PathRequestModifierTests {
    @Test func appliesPathModifierToRequest() {
        let request = DummyRequest().appending(path: "somePath")
        
        #expect(request.allModifiers.contains(where: {$0 is PathRequestModifier<String>}))
        
        let request2 = DummyRequest().appending(paths: "somePath")
        
        #expect(request2.allModifiers.contains(where: {$0 is PathRequestModifier<String>}))
    }
}

extension Tag {
    @Tag internal static var path: Self
}
