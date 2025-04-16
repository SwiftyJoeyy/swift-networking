//
//  AnyResultBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import Networking

@Suite(.tags(.resultBuilders))
struct AnyResultBuilderTests {
    typealias StringBuilder = AnyResultBuilder<String>
    private func build(@StringBuilder _ action: () -> [String]) -> [String] {
        return action()
    }
    
    @Test func buildBlockWithMultipleStrings() {
        let strings = build {
            "Test 1"
            "Test 2"
        }
        
        let expectedStrings = ["Test 1", "Test 2"]
        #expect(strings == expectedStrings)
    }

    @Test func buildArray() {
        let expectedStrings = ["Test 1", "Test 2"]
        let strings = build {
            for string in expectedStrings {
                string
            }
        }
        #expect(strings == expectedStrings)
    }

    @Test func buildOptionalString() {
        let valueString: String? = "Optional"
        let optionalString: String? = nil
        let strings = build {
            if let valueString {
                valueString
            }
            if let optionalString {
                optionalString
            }
        }
        
        #expect(strings == [valueString!])
    }
    
    @Test func buildConditionalStrings() {
        let strings = build {
            if true {
                "A true"
            }else {
                "A false"
            }
            
            if false {
                "B true"
            }else {
                "B false"
            }
            
            if true {
                "C true"
            }
            
            if false {
                "D false"
            }
        }
        
        let expectedStrings = [
            "A true",
            "B false",
            "C true"
        ]
        #expect(strings == expectedStrings)
    }
    
    @Test func buildLimitedAvailability() {
        let strings = build {
            if #available(macOS 16.0, *) {
                "A available"
            }else {
                "A unavailable"
            }
            
            if #available(macOS 12.0, *) {
                "B available"
            }else {
                "B unavailable"
            }
            
            if #available(macOS 12.0, *) {
                "C available"
            }
            
            if #available(macOS 16.0, *) {
                "D unavailable"
            }
        }
        
        let expectedStrings = [
            "A unavailable",
            "B available",
            "C available"
        ]
        #expect(strings == expectedStrings)
    }
}

extension AnyResultBuilderTests {
    struct TestHeader: RequestHeader {
        let key: String
        let value: String
        
        var headers: [String: String] {
            [key: value]
        }
    }
}

extension Tag {
    @Tag internal static var resultBuilders: Self
}
