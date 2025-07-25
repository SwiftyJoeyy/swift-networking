//
//  RequestHeaderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkingCore

/// Suite for testing the functionality of ``RequestHeader``.
@Suite(.tags(.requestModifiers, .headers))
struct RequestHeaderTests {
// MARK: - Properties
    /// ``URL`` for testing.
    private let url = URL(string: "example.com")!
    
// MARK: - Header Tests
    /// Checks that ``Header`` is correctly converted to ``[String: String]``.
    @Test func headerCreatesCorrectHeaders() {
        let header = Header("Authorization", value: "Bearer token")
        #expect(header.key == "Authorization")
        #expect(header.value == "Bearer token")
        #expect(header.headers == ["Authorization": "Bearer token"])
    }
    
    @Test func headerWithNilValueDoesNotCreateHeader() {
        let key = "key"
        do {
            let value: String? = nil
            let header = Header(key, value: value)
            #expect(header.key == key)
            #expect(header.headers.isEmpty)
        }
        do {
            let value: Int? = nil
            let header = Header(key, value: value)
            #expect(header.key == key)
            #expect(header.headers.isEmpty)
        }
        do {
            let value: Double? = nil
            let header = Header(key, value: value)
            #expect(header.key == key)
            #expect(header.headers.isEmpty)
        }
        do {
            let value: Bool? = nil
            let header = Header(key, value: value)
            #expect(header.key == key)
            #expect(header.headers.isEmpty)
        }
    }
    
    @Test func headerModifyingRequest() throws {
        let header = Header("Accept", value: "application/json")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try header.modifying(request)
        
        #expect(request.allHTTPHeaderFields?["Accept"] == "application/json")
    }
    
    @Test func headerModifyingRequestWithDuplicateKeys() throws {
        let header = Header("Accept", value: "application/json")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("test", forHTTPHeaderField: "Accept")
        request = try header.modifying(request)
        
        #expect(request.allHTTPHeaderFields?["Accept"] == "application/json")
    }

    @Test func headerWithNonStringValueConvertedToString() {
        let key = "key"
        do {
            let expectedHeader = Header(key, value: "1")
            let header = Header(key, value: 1)
            #expect(header == expectedHeader)
        }
        do {
            let expectedHeader = Header(key, value: "1.0")
            let header = Header(key, value: 1.0)
            #expect(header == expectedHeader)
        }
        do {
            let expectedHeader = Header(key, value: true)
            let header = Header(key, value: true)
            #expect(header == expectedHeader)
        }
    }
}

// MARK: - HeadersGroup Tests
extension RequestHeaderTests {
    @Test func groupInitWithNonOptionalDictionary() {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "User-Agent": "SwiftTest"
        ]
        let group = HeadersGroup(headers)
        
        #expect(group.headers.count == 2)
        #expect(group.headers["Content-Type"] == "application/json")
        #expect(group.headers["User-Agent"] == "SwiftTest")
    }
    
    @Test func groupInitWithOptionalDictionary() {
        let headers: [String: String?] = [
            "Content-Type": "application/json",
            "User-Agent": nil
        ]
        let group = HeadersGroup(headers)
        
        #expect(group.headers.count == 1)
        #expect(group.headers["Content-Type"] == "application/json")
        #expect(group.headers["User-Agent"] == nil)
    }
    
    @Test func groupInitWithHeadersBuilder() {
        let group = HeadersGroup {
            DummyHeader(headers: ["Content-Type": "application/json"])
            DummyHeader(headers: ["User-Agent": "1"])
        }
        
        #expect(group.headers.count == 2)
        #expect(group.headers["Content-Type"] == "application/json")
        #expect(group.headers["User-Agent"] == "1")
    }
    
    @Test func groupModifyingRequest() throws {
        let headers: [String: String] = ["X-Test": "true", "X-Feature": "on"]
        let group = HeadersGroup(headers)
        var request = URLRequest(url: url)
        
        request = try group.modifying(request)
        
        #expect(request.allHTTPHeaderFields?["X-Test"] == "true")
        #expect(request.allHTTPHeaderFields?["X-Feature"] == "on")
    }
    
    @Test func groupModifyingRequestWithDuplicateKeys() throws {
        var request = URLRequest(url: url)
        request.setValue("OldToken", forHTTPHeaderField: "Authorization")
        
        let group = HeadersGroup(["Authorization": "NewToken"])
        request = try group.modifying(request)
        
        #expect(request.allHTTPHeaderFields?["Authorization"] == "NewToken")
    }
}

// MARK: - Description Tests
extension RequestHeaderTests {
    @Test func descriptionIsEmptyForNoHeaders() {
        let header = DummyHeader(headers: [:])
        let result = header.description
        
        #expect(result.contains("DummyHeader = []"))
    }
    
    @Test func descriptionIncludesHeaders() {
        let header = DummyHeader(headers: ["X-Test": "Value", "Auth": "Bearer xyz"])
        let result = header.description
        
        #expect(result.contains("X-Test"))
        #expect(result.contains("Value"))
        #expect(result.contains("Auth"))
        #expect(result.contains("Bearer xyz"))
    }
}

// MARK: - Modifier Tests
extension RequestHeaderTests {
    @Test func appliesHeadersModifierToRequest() {
        let header = DummyHeader(headers: ["A": "1"])
        do {
            let request = DummyRequest()
                .additionalHeaders {
                    header
                }
            
            let modifiedRequest = getModified(request, DummyRequest.self, DummyHeader.self)
            #expect(modifiedRequest?.modifier.headers == header.headers)
        }
        
        do {
            let request = DummyRequest()
                .additionalHeader(header)
            
            let modifiedRequest = getModified(request, DummyRequest.self, DummyHeader.self)
            #expect(modifiedRequest?.modifier.headers == header.headers)
        }
    }
    
    @Test func appliesHeaderModifierToRequestUsingOverload() {
        let header = (key: "A", value: "1")
        let request = DummyRequest()
            .additionalHeader(header.key, value: header.value)
        
        let modifiedRequest = getModified(request, DummyRequest.self, Header.self)
        let expectedHeaders = [header.key: header.value]
        #expect(modifiedRequest?.modifier.headers == expectedHeaders)
    }
    
    struct DummyHeader: RequestHeader {
        let headers: [String: String]
    }
}

extension Tag {
    @Tag internal static var headers: Self
}
