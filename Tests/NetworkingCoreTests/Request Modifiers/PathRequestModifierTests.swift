//
//  PathRequestModifierTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .path))
struct PathRequestModifierTests {
    @Test func appendingSinglePathComponent() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test"])
        
        request = try modifier.modifying(request)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/test")
    }
    
    @Test func appendingMultiplePathComponents() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier(["test", "path", "123"])
        
        request = try modifier.modifying(request)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/test/path/123")
    }
    
    @Test func appendingPathComponentToExistingPath() throws {
        var request = URLRequest(url: URL(string: "https://example.com/base")!)
        let modifier = PathRequestModifier(["additional"])
        
        request = try modifier.modifying(request)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/base/additional")
    }
    
    @Test func appendingEmptyPathDoesNotChangeURL() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let modifier = PathRequestModifier([""])
        
        request = try modifier.modifying(request)
        let url = request.url?.absoluteString
        
        #expect(url == "https://example.com/")
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
    @Test func appliesPathModifierToRequest() {
        let request = DummyRequest()
            .appending("somePath", "v2")
        
        let modified = getModified(request, DummyRequest.self, PathRequestModifier.self)
        #expect(modified != nil)
    }
}

extension Tag {
    @Tag internal static var path: Self
}
