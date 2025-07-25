//
//  RequestBodyTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .body))
struct RequestBodyTests {
    private let url = URL(string: "example.com")!
    
// MARK: - ContentType Tests
    @Test(arguments: [
        ContentType(.applicationFormURLEncoded),
        ContentType(.applicationJson),
        ContentType("Custom")
    ])
    func requestBodySetsContentType(expectedContentType: ContentType) throws {
        let body = "Test Body".data(using: .utf8)
        let urlRequest = URLRequest(url: url)
        let modifier = RequestBodyStub(
            contentType: expectedContentType,
            result: .success(body)
        )
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let contentType = modifiedRequest.allHTTPHeaderFields?["Content-Type"]
        #expect(contentType == expectedContentType.headers["Content-Type"])
    }
    
    @Test func requestBodyOverwritesContentType() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest = try ContentType(.applicationFormURLEncoded)
            .modifying(urlRequest)
        let expectedContentType = ContentType(.applicationJson)
        let modifier = RequestBodyStub(
            contentType: expectedContentType,
            result: .success(Data())
        )
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let contentType = modifiedRequest.allHTTPHeaderFields?["Content-Type"]
        #expect(contentType == expectedContentType.headers["Content-Type"])
    }
    
    @Test func requestBodyWithoutContentTypeWithExistingContentType() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest = try ContentType(.applicationFormURLEncoded)
            .modifying(urlRequest)
        let expectedHeaders = urlRequest.allHTTPHeaderFields
        let modifier = RequestBodyStub(contentType: nil, result: .success(nil))
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let headers = modifiedRequest.allHTTPHeaderFields
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
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
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
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
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
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let body = modifiedRequest.httpBody
        #expect(body == expectedBody)
    }
    
    @Test func requestBodyWithoutHTTPBody() throws {
        let urlRequest = URLRequest(url: url)
        let modifier = RequestBodyStub(
            contentType: ContentType(.applicationJson),
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        #expect(modifiedRequest == urlRequest)
    }
    
    @Test func requestBodyWithoutHTTPBodyWithExistingHTTPBody() throws {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = "Test Body".data(using: .utf8)
        let modifier = RequestBodyStub(
            contentType: nil,
            result: .success(nil)
        )
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        #expect(modifiedRequest == urlRequest)
    }
    
    @Test func requestBodyThrowsWithThrowingBody() throws {
        let urlRequest = URLRequest(url: url)
        let expectedError = NSError(domain: "Test", code: 10)
        let modifier = RequestBodyStub(contentType: nil, result: .failure(.custom(expectedError)))
        
        let networkingError = try #require(throws: NetworkingError.self) {
            try modifier.modifying(urlRequest)
        }
        var foundCorrectError = false
        if case NetworkingError.custom(let error) = networkingError {
            foundCorrectError = (error as NSError).domain == expectedError.domain
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
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
        let modified = getModified(request, DummyRequest.self, RequestBodyStub.self)
        #expect(modified != nil)
    }
}

extension RequestBodyTests {
    struct RequestBodyStub: RequestBody {
        let contentType: ContentType?
        let result: Result<Data?, NetworkingError>
    
        func body() throws(NetworkingError) -> Data? {
            return try result.get()
        }
    }
}

extension Tag {
    @Tag internal static var body: Self
}
