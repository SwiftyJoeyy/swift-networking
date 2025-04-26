//
//  URLResponseExtensionTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import NetworkingClient

@Suite(.tags(.utilities))
struct URLResponseExtensionTests {
    private let url = URL(string: "https://example.com")!
    
    @Test func knownStatusFromHTTPURLResponse() {
        let statusCode = ResponseStatus.ok
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode.rawValue,
            httpVersion: nil,
            headerFields: nil
        )!
        
        #expect(httpResponse.status == statusCode)
    }
    
    @Test func customStatusFromHTTPURLResponse() {
        let statusCode = 799
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        
        #expect(httpResponse.status == .custom(code: statusCode))
    }
    
    @Test func statusFromNonHTTPURLResponse() {
        let response = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        #expect(response.status == nil)
    }
}
