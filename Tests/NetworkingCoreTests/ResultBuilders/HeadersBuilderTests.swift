//
//  HeadersBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.resultBuilders))
struct HeadersBuilderTests {
    private func build(@HeadersBuilder _ action: () -> HeadersGroup) -> [String: String] {
        return action().headers
    }
    
    @Test func buildBlockWithMultipleHeaders() {
        let headers = build {
            TestHeader(key: "A", value: "1")
            TestHeader(key: "B", value: "2")
        }
        
        let expectedHeaders = ["A": "1", "B": "2"]
        #expect(headers == expectedHeaders)
    }

    @Test func buildArray() {
        let headersArray: [any RequestHeader] = [
            TestHeader(key: "A", value: "1"),
            TestHeader(key: "B", value: "2")
        ]
        let headers = build {
            for header in headersArray {
                header
            }
        }
        
        let expectedHeaders = ["A": "1", "B": "2"]
        #expect(headers == expectedHeaders)
    }

    @Test func buildArrayWithKeyConflictUsesLastValue() {
        let headersArray: [any RequestHeader] = [
            TestHeader(key: "A", value: "1"),
            TestHeader(key: "A", value: "2")
        ]
        let headers = build {
            for header in headersArray {
                header
            }
        }
        
        let expectedHeaders = ["A": "2"]
        #expect(headers == expectedHeaders)
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
            if #available(macOS 16.0, *) {
                TestHeader(key: "A", value: "available")
            }else {
                TestHeader(key: "A", value: "unavailable")
            }
            
            if #available(macOS 12.0, *) {
                TestHeader(key: "B", value: "available")
            }else {
                TestHeader(key: "B", value: "unavailable")
            }
            
            if #available(macOS 12.0, *) {
                TestHeader(key: "C", value: "available")
            }
            
            if #available(macOS 16.0, *) {
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
