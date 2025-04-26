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
    private let configurations = ConfigurationValues.mock
    private let url = URL(string: "example.com")!
    
    // MARK: - Header Tests
    /// Checks that ``Header`` is correctly converted to ``[String: String]``.
    @Test(arguments: [["test1": "1"], ["test2": "2"], ["test3": "3"]])
    func convertHeaderToDictionary(items: [String: String]) {
        let first = items.first!
        let header = Header(first.key, value: first.value)
        let expectedItems = items
        
        #expect(header.headers == expectedItems)
    }
    
    /// Checks that ``HeadersGroup`` header values are correctly converted to ``[String: String]``.
    @Test(arguments: [["test1": "1", "test11": "11"], ["test2": "2", "test22": "22"], ["test3": "3", "test33": "33"]])
    func convertHeadersGroupWithoutDuplicateKeysToDictionary(items: [String: String]) {
        let headers = items.map({Header($0.key, value: $0.value)})
        let group = HeadersGroup(headers)
        
        let expectedItems = items
        
        #expect(group.headers == expectedItems)
    }
    
    /// Checks that header is correcly encoded in to a ``URLRequest`` with empty headers.
    @Test func encodingHeaderIntoAURLRequestWithEmptyHeaders() throws {
        let urlRequest = URLRequest(url: url)
        let header = Header("test11", value: "11")
        let modifiedRequest = try header.modifying(urlRequest, with: configurations)
        
        let expectedItems = header.headers
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
    /// Checks that header is correcly encoded in to a ``URLRequest`` with non empty headers.
    @Test func encodingHeaderIntoAURLRequestWithNonEmptyHeaders() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("9", forHTTPHeaderField: "test")
        let header = Header("test11", value: "11")
        let modifiedRequest = try header.modifying(urlRequest, with: configurations)
        
        let expectedItems = ["test": "9", "test11": "11"]
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
}

// MARK: - HeadersGroup Tests
extension RequestHeaderTests {
    /// Checks that ``HeadersGroup`` header values are correctly converted to ``[String: String]`` after appending a duplicate key with different value.
    @Test func convertHeadersGroupAfterAddingDuplicateKeysAndDifferentValuesToDictionary() {
        let items = ["test1": "1", "test11": "11"]
        var headers = items.map({Header($0.key, value: $0.value)})
        headers.append(Header("test11", value: "22"))
        let group = HeadersGroup(headers)
        
        let expectedItems = ["test1": "1", "test11": "22"]
        
        #expect(group.headers == expectedItems)
    }
    
    /// Checks that ``HeadersGroup`` header values are correctly converted to ``[String: String]`` after appending headers to an array containing duplicate keys with different values.
    @Test func convertHeadersGroupContainingDuplicateKeysAndDifferentValuesToDictionary() {
        let items = ["test1": "1", "test11": "22"]
        var headers = [Header("test11", value: "11")]
        headers.append(contentsOf: items.map({Header($0.key, value: $0.value)}))
        let group = HeadersGroup(headers)
        
        let expectedItems = ["test1": "1", "test11": "22"]
        
        #expect(group.headers == expectedItems)
    }
    
    /// Checks that ``HeadersGroup`` header values are correctly converted to ``[String: String]`` after appending a duplicate key and value.
    @Test func convertHeadersGroupAfterAddingDuplicateKeysAndValuesToDictionary() {
        let items = ["test1": "1", "test11": "11"]
        var headers = items.map({Header($0.key, value: $0.value)})
        headers.append(Header("test11", value: "11"))
        let group = HeadersGroup(headers)
        
        let expectedItems = ["test1": "1", "test11": "11"]
        
        #expect(group.headers == expectedItems)
    }
    
    /// Checks that ``HeadersGroup`` header values are correctly converted to ``[String: String]`` after appending headers to an array containing duplicate keys values.
    @Test func convertHeadersGroupContainingDuplicateKeysAndValuesToDictionary() {
        let items = ["test1": "1", "test11": "11"]
        var headers = [Header("test11", value: "11")]
        headers.append(contentsOf: items.map({Header($0.key, value: $0.value)}))
        let group = HeadersGroup(headers)
        
        let expectedItems = ["test1": "1", "test11": "11"]
        
        #expect(group.headers == expectedItems)
    }
    
    /// Checks that headers group are correcly encoded in to a ``URLRequest`` with empty headers.
    @Test func encodingHeadersGroupIntoAURLRequestWithEmptyHeaders() throws {
        let urlRequest = URLRequest(url: url)
        let headers = HeadersGroup {
            Header("test11", value: "11")
            Header("test22", value: "22")
        }
        let modifiedRequest = try headers.modifying(urlRequest, with: configurations)
        
        let expectedItems = headers.headers
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
    /// Checks that headers group are correcly encoded in to a ``URLRequest`` with non empty headers.
    @Test func encodingHeadersGroupIntoAURLRequestWithNonEmptyHeaders() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("9", forHTTPHeaderField: "test")
        let headers = HeadersGroup {
            Header("test11", value: "11")
            Header("test22", value: "22")
        }
        let modifiedRequest = try headers.modifying(urlRequest, with: configurations)
        
        let expectedItems = ["test": "9", "test11": "11", "test22": "22"]
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
    @Test func initWithPlainDictionary() {
        let expectedValue = [
            "Accept": "application/json",
            "Cache-Control": "no-cache"
        ]
        let group = HeadersGroup(expectedValue)
        
        #expect(group.headers == expectedValue)
    }
    
    @Test func initWithOptionalDictionary() {
        let group = HeadersGroup([
            "Accept": "application/json",
            "Authorization": nil,
            "Cache-Control": "no-cache"
        ])
        
        let expectedValue = [
            "Accept": "application/json",
            "Cache-Control": "no-cache"
        ]
        #expect(group.headers == expectedValue)
    }
    
    @Test func initWithRequestHeadersArray() {
        let header1 = DummyHeader(headers: ["A": "1"])
        let header2 = DummyHeader(headers: ["B": "2"])
        let group = HeadersGroup([header1, header2])
        
        let expectedValue = ["A": "1", "B": "2"]
        #expect(group.headers == expectedValue)
    }
    
    @Test func initWithHeadersBuilder() {
        let group = HeadersGroup {
            HeadersGroup(["X-Trace": "trace-123"])
            DummyHeader(headers: ["A": "1"])
        }
        
        let expectedValue = ["X-Trace": "trace-123", "A": "1"]
        #expect(group.headers == expectedValue)
    }
    
    struct DummyHeader: RequestHeader {
        let headers: [String: String]
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
}

// MARK: - Modifier Tests
extension RequestHeaderTests {
    @Test func appliesAdditionalHeadersModifierToRequest() {
        let request = DummyRequest()
            .additionalHeaders {
                DummyHeader(headers: ["A": "1"])
            }
        
        #expect(request.allModifiers.contains(where: {$0 is HeadersGroup}))
    }
}

extension Tag {
    @Tag internal static var headers: Self
}
