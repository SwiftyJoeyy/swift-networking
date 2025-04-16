//
//  CURLLogFactoryTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import Networking

@Suite(.tags(.utilities, .logging))
struct CURLLogFactoryTests {
    @Test func basicGETRequest() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "GET"

        let curl = CURLLogFactory.make(for: request)
        
        #expect(curl.contains("cURL"))
        #expect(curl.contains("--request GET"))
        #expect(curl.contains("--url 'https://example.com'"))
    }
    
    @Test func basicRequestWithoutMethod() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = nil

        let curl = CURLLogFactory.make(for: request)
        
        #expect(curl.contains("cURL"))
        #expect(curl.contains("--request GET"))
        #expect(curl.contains("--url 'https://example.com'"))
    }
    
    @Test func requestWithHeaders() {
        var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer token123"
        ]

        let curl = CURLLogFactory.make(for: request)
        
        #expect(curl.contains("--request POST"))
        #expect(curl.contains("--header 'Content-Type: application/json'"))
        #expect(curl.contains("--header 'Authorization: Bearer token123'"))
    }

    @Test func requestWithUTF8Body() {
        var request = URLRequest(url: URL(string: "https://api.example.com")!)
        request.httpMethod = "POST"
        request.httpBody = #"{"key":"value"}"#.data(using: .utf8)

        let curl = CURLLogFactory.make(for: request)
        
        #expect(curl.contains("--data '{\"key\":\"value\"}'"))
    }

    @Test func requestWithBinaryBody() {
        var request = URLRequest(url: URL(string: "https://api.example.com/upload")!)
        request.httpMethod = "PUT"
        request.httpBody = Data([0xDE, 0xAD, 0xBE, 0xEF])

        let curl = CURLLogFactory.make(for: request)

        #expect(curl.contains("--data"))
        #expect(curl.contains("echo 'DEADBEEF' | xxd -p -r"))
    }
}

extension Tag {
    @Tag internal static var logging: Self
}
