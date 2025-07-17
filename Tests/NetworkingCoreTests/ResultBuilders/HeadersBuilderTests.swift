//
//  HeadersBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
@_spi(Internal) @testable import NetworkingCore

@Suite(.tags(.resultBuilders))
struct HeadersBuilderTests {
// MARK: - Functions
    private func buildHeader(
        @HeadersBuilder _ action: () -> some RequestHeader
    ) -> some RequestHeader {
        return action()
    }
    private func build(
        @HeadersBuilder _ action: () -> some RequestHeader
    ) -> [String: String] {
        return buildHeader(action).headers
    }
    
// MARK: - Tests
    @Test func buildBlockWithNoHeaders() {
        let headers = build { }
        
        #expect(headers == [:])
    }
    
    @Test func buildBlockWithOneHeader() {
        let headers = build {
            TestHeader(key: "A", value: "1")
        }
        
        let expectedHeaders = ["A": "1"]
        #expect(headers == expectedHeaders)
    }
    
    @Test func buildBlockWithMultipleHeaders() {
        do {
            let headers = build {
                TestHeader(key: "A", value: "1")
                TestHeader(key: "B", value: "2")
            }
            
            let expectedHeaders = ["A": "1", "B": "2"]
            #expect(headers == expectedHeaders)
        }
        
        do {
            let headers = build {
                TestHeader(key: "A", value: "1")
                TestHeader(key: "B", value: "2")
                TestHeader(key: "C", value: "3")
                TestHeader(key: "D", value: "4")
                TestHeader(key: "E", value: "5")
                TestHeader(key: "F", value: "6")
                TestHeader(key: "G", value: "7")
                TestHeader(key: "H", value: "8")
                TestHeader(key: "I", value: "9")
                TestHeader(key: "J", value: "10")
            }
            
            let expectedHeaders = ["A": "1", "B": "2", "C": "3", "D": "4", "E": "5", "F": "6", "G": "7", "H": "8", "I": "9", "J": "10"]
            #expect(headers == expectedHeaders)
        }
    }

    @Test func buildOptionalHeader() {
        let valueHeader: TestHeader? = TestHeader(key: "Opt", value: "Value")
        let optionalHeader: TestHeader? = nil
        let headers = build {
            if let valueHeader {
                valueHeader
            }
            if let optionalHeader {
                optionalHeader
            }
        }
        
        let expectedHeaders = ["Opt": "Value"]
        #expect(headers == expectedHeaders)
    }
    
    @Test func buildConditionalHeaders() {
        let headers = build {
            if true {
                TestHeader(key: "A", value: "true")
            }else {
                TestHeader(key: "A", value: "false")
            }
            
            if false {
                TestHeader(key: "B", value: "true")
            }else {
                TestHeader(key: "B", value: "false")
            }
            
            if true {
                TestHeader(key: "C", value: "true")
            }
            
            if false {
                TestHeader(key: "D", value: "false")
            }
        }
        
        let expectedHeaders = [
            "A": "true",
            "B": "false",
            "C": "true"
        ]
        #expect(headers == expectedHeaders)
    }
    
    @Test func buildLimitedAvailability() {
        let headers = build {
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestHeader(key: "A", value: "available")
            }else {
                TestHeader(key: "A", value: "unavailable")
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestHeader(key: "B", value: "available")
            }else {
                TestHeader(key: "B", value: "unavailable")
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestHeader(key: "C", value: "available")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestHeader(key: "D", value: "unavailable")
            }
        }
        
        let expectedHeaders = [
            "A": "unavailable",
            "B": "available",
            "C": "available"
        ]
        #expect(headers == expectedHeaders)
    }
    
    @Test func headersModifyingURLRequest() throws {
        let header = buildHeader {
            if true {
                TestHeader(key: "D", value: "val")
            }else {
                TestHeader(key: "A", value: "val")
            }
            
            if false {
                TestHeader(key: "E", value: "val")
            }else {
                TestHeader(key: "F", value: "val")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestHeader(key: "C", value: "val")
            }
            
            TestHeader(key: "B", value: "val")
        }
        
        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        let modified = try header.modifying(urlRequest)
        
        #expect(modified.allHTTPHeaderFields?.count == 3)
        #expect(modified.allHTTPHeaderFields?["D"] == "val")
        #expect(modified.allHTTPHeaderFields?["B"] == "val")
        #expect(modified.allHTTPHeaderFields?["F"] == "val")
    }
    
    @Test func headerDescription() throws {
        let header = buildHeader {
            if true {
                TestHeader(key: "D", value: "val")
            }else {
                TestHeader(key: "A", value: "val")
            }
            
            if false {
                TestHeader(key: "E", value: "val")
            }else {
                TestHeader(key: "F", value: "val")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestHeader(key: "C", value: "val")
            }
            
            TestHeader(key: "B", value: "val")
        }
        
        let result = header.description
        
        #expect(result.contains("D : val"))
        #expect(result.contains("B : val"))
        #expect(result.contains("F : val"))
        #expect(!result.contains("C : val"))
        #expect(!result.contains("A : val"))
        #expect(!result.contains("E : val"))
    }
}

extension HeadersBuilderTests {
    struct TestHeader: RequestHeader {
        let key: String
        let value: String
        
        var headers: [String: String] {
            [key: value]
        }
    }
}
