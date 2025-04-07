//
//  RequestBodyTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Suite(.tags(.body))
struct RequestBodyTests {
    private let url = URL(string: "example.com")!
    private let configurations = ConfigurationValues.mock
    
    @Test func requestBodyWithoutHTTPBodyWithoutContentType() throws {
        let urlRequest = URLRequest(url: url)
        let expectedHeaders = urlRequest.allHTTPHeaderFields ?? [:]
        let modifier = RequestBodyStub(contentType: nil, result: .success(nil))
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        let headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        #expect(body == nil)
        #expect(headers == expectedHeaders)
    }
    
// MARK: - ContentType Tests
    @Test(arguments: [
        ContentType(.applicationFormURLEncoded),
        ContentType(.applicationJson),
        ContentType(.custom("Custom"))
    ])
    func requestBodySetsContentTypeWithoutBody(expectedContentType: ContentType) throws {
        let urlRequest = URLRequest(url: url)
        let expectedHeaders = expectedContentType.headers
        let modifier = RequestBodyStub(
            contentType: expectedContentType,
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        var headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        for header in headers {
            guard expectedHeaders[header.key] == nil else {continue}
            headers.removeValue(forKey: header.key)
        }
        #expect(headers == expectedHeaders)
    }
    
    @Test(arguments: [
        ContentType(.applicationFormURLEncoded),
        ContentType(.applicationJson),
        ContentType(.custom("Custom"))
    ])
    func requestBodySetsContentTypeWithBody(expectedContentType: ContentType) throws {
        let body = "Test Body".data(using: .utf8)
        let urlRequest = URLRequest(url: url)
        let expectedHeaders = expectedContentType.headers
        let modifier = RequestBodyStub(
            contentType: expectedContentType,
            result: .success(body)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        var headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        for header in headers {
            guard expectedHeaders[header.key] == nil else {continue}
            headers.removeValue(forKey: header.key)
        }
        #expect(headers == expectedHeaders)
    }
    
    @Test func requestBodyOverwritesContentType() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest = try ContentType(.applicationFormURLEncoded)
            .modifying(urlRequest, with:configurations)
        let expectedContentType = ContentType(.applicationJson)
        let expectedHeaders = expectedContentType.headers
        let modifier = RequestBodyStub(
            contentType: expectedContentType,
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        var headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        for header in headers {
            guard expectedHeaders[header.key] == nil else {continue}
            headers.removeValue(forKey: header.key)
        }
        #expect(headers == expectedHeaders)
    }
    
    @Test func requestBodyWithoutContentTypeWithBody() throws {
        let body = "Test Body".data(using: .utf8)
        let urlRequest = URLRequest(url: url)
        let expectedHeaders = urlRequest.allHTTPHeaderFields ?? [:]
        let modifier = RequestBodyStub(contentType: nil, result: .success(body))
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        #expect(headers == expectedHeaders)
    }
    
    @Test func requestBodyWithoutContentTypeWithExistingContentType() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest = try ContentType(.applicationFormURLEncoded)
            .modifying(urlRequest, with: configurations)
        let expectedHeaders = urlRequest.allHTTPHeaderFields
        let modifier = RequestBodyStub(contentType: nil, result: .success(nil))
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let headers = modifiedRequest.allHTTPHeaderFields ?? [:]
        #expect(headers == expectedHeaders)
    }

// MARK: - HTTP body Tests
    @Test func requestBodySetsHTTPBodyWithoutContentType() throws {
        let urlRequest = URLRequest(url: url)
        let expectedBody = "Test Body".data(using: .utf8)
        let modifier = RequestBodyStub(
            contentType: nil,
            result: .success(expectedBody)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        #expect(body == expectedBody)
    }
    
    @Test func requestBodySetsHTTPBodyWithContentType() throws {
        let urlRequest = URLRequest(url: url)
        let expectedBody = "Test Body".data(using: .utf8)
        let modifier = RequestBodyStub(
            contentType: ContentType(.applicationJson),
            result: .success(expectedBody)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        #expect(body == expectedBody)
    }
    
    @Test func requestBodyOverwritesHTTPBody() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = "Test Body".data(using: .utf8)
        let expectedBody = "Test Body2".data(using: .utf8)
        let modifier = RequestBodyStub(
            contentType: nil,
            result: .success(expectedBody)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        #expect(body == expectedBody)
    }
    
    @Test func requestBodyWithoutHTTPBodyWithContentType() throws {
        let urlRequest = URLRequest(url: url)
        let modifier = RequestBodyStub(
            contentType: ContentType(.applicationJson),
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        #expect(body == nil)
    }
    
    @Test func requestBodyWithoutHTTPBodyWithExistingHTTPBody() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = "Test Body".data(using: .utf8)
        let modifier = RequestBodyStub(
            contentType: nil,
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let body = modifiedRequest.httpBody
        #expect(body == nil)
    }
    
    @Test func requestBodyThrowsWithThrowingBody() {
        let urlRequest = URLRequest(url: url)
        let expectedError = NSError(domain: "Test", code: 10)
        let modifier = RequestBodyStub(contentType: nil, result: .failure(expectedError))
        
        #expect(throws: expectedError) {
            try modifier.modifying(
                urlRequest,
                with: configurations
            )
        }
    }
}

// MARK: - Modifier Tests
extension RequestBodyTests {
    @Test func appliesBodyModifierToRequest() {
        let request = DummyRequest()
            .body {
                RequestBodyStub(
                    contentType: ContentType(.applicationJson),
                    result: .success(nil)
                )
            }
        
        #expect(request.allModifiers.contains(where: {$0 is RequestBodyStub}))
    }
}

extension RequestBodyTests {
    struct RequestBodyStub: RequestBody {
        let contentType: ContentType?
        let result: Result<Data?, any Error>
    
        func body(for configurations: borrowing ConfigurationValues) throws -> Data? {
            return try result.get()
        }
    }
}
