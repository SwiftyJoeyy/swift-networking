//
//  RequestModifiersTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Test func applyingHTTPMethodToURLRequest() throws {
    let method = RequestMethod.post
    let urlRequest = URLRequest(url: URL(string: "google.com")!)
    
    let modifier = HTTPMethodRequestModifier(method)
    let newRequest = try modifier.modified(urlRequest)
    
    #expect(newRequest.httpMethod == method.rawValue)
}

@Test func applyingTimeoutIntervalToURLRequest() throws {
    let timeout: TimeInterval = 1000
    let urlRequest = URLRequest(url: URL(string: "google.com")!)
    
    let modifier = TimeoutRequestModifier(timeout)
    let newRequest = try modifier.modified(urlRequest)
    
    #expect(newRequest.timeoutInterval == timeout)
}
