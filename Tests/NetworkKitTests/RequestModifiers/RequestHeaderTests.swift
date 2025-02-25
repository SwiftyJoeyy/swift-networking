//
//  RequestHeaderTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkKit

/// Suite for testing the functionality of ``RequestHeader``.
@Suite(.tags(.headers))
struct RequestHeaderTests {
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
        let urlRequest = URLRequest(url: URL(string: "google.com")!)
        let header = Header("test11", value: "11")
        let modifiedRequest = try header.modified(urlRequest)
        
        let expectedItems = header.headers
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
    /// Checks that header is correcly encoded in to a ``URLRequest`` with non empty headers.
    @Test func encodingHeaderIntoAURLRequestWithNonEmptyHeaders() throws {
        var urlRequest = URLRequest(url: URL(string: "google.com")!)
        urlRequest.setValue("9", forHTTPHeaderField: "test")
        let header = Header("test11", value: "11")
        let modifiedRequest = try header.modified(urlRequest)
        
        let expectedItems = ["test": "9", "test11": "11"]
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
// MARK: - HeadersGroup Tests
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
        let urlRequest = URLRequest(url: URL(string: "google.com")!)
        let headers = HeadersGroup {
            Header("test11", value: "11")
            Header("test22", value: "22")
        }
        let modifiedRequest = try headers.modified(urlRequest)
        
        let expectedItems = headers.headers
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
    
    /// Checks that headers group are correcly encoded in to a ``URLRequest`` with non empty headers.
    @Test func encodingHeadersGroupIntoAURLRequestWithNonEmptyHeaders() throws {
        var urlRequest = URLRequest(url: URL(string: "google.com")!)
        urlRequest.setValue("9", forHTTPHeaderField: "test")
        let headers = HeadersGroup {
            Header("test11", value: "11")
            Header("test22", value: "22")
        }
        let modifiedRequest = try headers.modified(urlRequest)
        
        let expectedItems = ["test": "9", "test11": "11", "test22": "22"]
        
        #expect(modifiedRequest.allHTTPHeaderFields == expectedItems)
    }
}
