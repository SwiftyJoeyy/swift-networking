//
//  RequestHeaderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
@testable import NetworkingCore

/// Suite for testing the functionality of ``RequestHeader``.
@Suite(.tags(.requestModifiers, .headers))
struct RequestHeaderTests {
// MARK: - Properties
    private let configurations = ConfigurationValues.mock
    
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
    
    @Test func headerModifyingRequest() throws {
        let header = Header("Accept", value: "application/json")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request = try header.modifying(request, with: configurations)
        
        #expect(request.allHTTPHeaderFields?["Accept"] == "application/json")
    }
    
    @Test func headerModifyingRequestWithDuplicateKeys() throws {
        let header = Header("Accept", value: "application/json")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("test", forHTTPHeaderField: "Accept")
        request = try header.modifying(request, with: configurations)
        
        #expect(request.allHTTPHeaderFields?["Accept"] == "application/json")
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
        
        request = try group.modifying(request, with: .init())
        
        #expect(request.allHTTPHeaderFields?["X-Test"] == "true")
        #expect(request.allHTTPHeaderFields?["X-Feature"] == "on")
    }
    
    @Test func groupModifyingRequestWithDuplicateKeys() throws {
        var request = URLRequest(url: url)
        request.setValue("OldToken", forHTTPHeaderField: "Authorization")
        
        let group = HeadersGroup(["Authorization": "NewToken"])
        request = try group.modifying(request, with: .init())
        
        #expect(request.allHTTPHeaderFields?["Authorization"] == "NewToken")
    }
}

// MARK: - AcceptLanguage Tests
extension RequestHeaderTests {
    @Test func acceptLanguageHeader() {
        let language = "en-US"
        let header = AcceptLanguage(language)
        #expect(header.headers == ["Accept-Language": language])
    }
}

// MARK: - ContentDisposition Tests
extension RequestHeaderTests {
    @Test func contentDispositionWithRawValue() {
        let value = "inline"
        let header = ContentDisposition(value)
        #expect(header.headers == ["Content-Disposition": value])
    }
    
    @Test func contentDispositionWithNameOnly() {
        let name = "upload"
        let header = ContentDisposition(name: name)
        
        let expectedValue = #"form-data; name="\#(name)""#
        #expect(header.headers == ["Content-Disposition": expectedValue])
    }
    
    @Test func contentDispositionWithNameAndFilename() {
        let name = "upload"
        let fileName = "file.txt"
        let header = ContentDisposition(name: name, fileName: fileName)
        
        let expectedValue = #"form-data; name="\#(name)"; filename="\#(fileName)""#
        #expect(header.headers == ["Content-Disposition": expectedValue])
    }
}

// MARK: - ContentType Tests
extension RequestHeaderTests {
    @Test func applicationFormURLEncoded() {
        let header = ContentType(.applicationFormURLEncoded)
        
        let expectedValue = "application/x-www-form-urlencoded"
        #expect(header.type.value == expectedValue)
        #expect(header.headers == ["Content-Type": expectedValue])
    }
    
    @Test func applicationJson() {
        let header = ContentType(.applicationJson)
        
        let expectedValue = "application/json"
        #expect(header.type.value == expectedValue)
        #expect(header.headers == ["Content-Type": expectedValue])
    }
    
    @Test func multipartFormData() {
        let boundary = "abc123"
        let header = ContentType(.multipartFormData(boundary: boundary))
        
        let expectedValue = "multipart/form-data; boundary=\(boundary)"
        #expect(header.type.value == expectedValue)
        #expect(header.headers == ["Content-Type": expectedValue])
    }
    
    @Test func customContentType() {
        let type = "text/plain; charset=utf-8"
        let header = ContentType(.custom(type))
        
        #expect(header.type.value == type)
        #expect(header.headers["Content-Type"] == type)
    }
    
#if canImport(UniformTypeIdentifiers)
    @Test func supportedMimeContentType() {
        let type = UTType.plainText
        let header = ContentType(.mime(type))
        
        let value = type.preferredMIMEType
        
        #expect(header.type.value == value)
        #expect(header.headers["Content-Type"] == value)
    }
    
    @Test func unsupportedMimeContentType() {
        let type = UTType.text
        let header = ContentType(.mime(type))
        
        let value = "Unsupported"
        
        #expect(header.type.value == value)
        #expect(header.headers["Content-Type"] == value)
    }
#endif
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
    @Test func appliesAdditionalHeadersModifierToRequest() {
        let header = DummyHeader(headers: ["A": "1"])
        let request = DummyRequest()
            .additionalHeaders {
                header
            }
        
        let modifiedRequest = getModified(request, DummyRequest.self, DummyHeader.self)
        #expect(modifiedRequest?.modifier.headers == header.headers)
    }
    
    struct DummyHeader: RequestHeader {
        let headers: [String: String]
    }
}

extension Tag {
    @Tag internal static var headers: Self
}
