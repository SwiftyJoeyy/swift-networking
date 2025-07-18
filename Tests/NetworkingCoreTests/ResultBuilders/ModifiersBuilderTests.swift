//
//  ModifiersBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.resultBuilders))
struct ModifiersBuilderTests {
// MARK: - Functions
    private func build(
        @ModifiersBuilder _ action: () -> some RequestModifier
    ) -> some RequestModifier {
        return action()
    }
    
// MARK: - Tests
    @Test func buildBlockWithNoModifiers() {
        let modifier = build { }
        
        #expect(modifier is EmptyModifier)
    }
    
    @Test func buildBlockWithOneModifier() {
        let modifier = build {
            TestModifier<Int>()
        }
        
        #expect(modifier is TestModifier<Int>)
    }
    
    @Test func buildBlockWithMultipleModifiers() {
        do {
            let modifier = build {
                TestModifier<Int>()
                TestModifier<String>()
            }
            
            #expect(
                modifier is _TupleModifier<
                    TestModifier<Int>,
                    TestModifier<String>,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier,
                    EmptyModifier
                >
            )
        }
        
        do {
            let modifier = build {
                TestModifier<Int>()
                TestModifier<String>()
                TestModifier<Int>()
                TestModifier<String>()
                TestModifier<Int>()
                TestModifier<String>()
                TestModifier<Int>()
                TestModifier<String>()
                TestModifier<Int>()
                TestModifier<String>()
            }
            
            #expect(
                modifier is _TupleModifier<
                TestModifier<Int>,
                TestModifier<String>,
                TestModifier<Int>,
                TestModifier<String>,
                TestModifier<Int>,
                TestModifier<String>,
                TestModifier<Int>,
                TestModifier<String>,
                TestModifier<Int>,
                TestModifier<String>
                >
            )
        }
    }
    
    @Test func buildOptionalModifier() {
        let valueModifier: TestModifier<Int>? = TestModifier()
        let optionalModifier: TestModifier<String>? = nil
        let modifier = build {
            if let valueModifier {
                valueModifier
            }
            if let optionalModifier {
                optionalModifier
            }
        }
        
        #expect(
            modifier is _TupleModifier<
            _OptionalModifier<TestModifier<Int>>,
            _OptionalModifier<TestModifier<String>>,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier
            >
        )
    }
    
    @Test func buildConditionalModifier() {
        let modifier = build {
            if true {
                TestModifier<Int>()
            }else {
                TestModifier<Never>()
            }
            
            if false {
                TestModifier<Never>()
            }else {
                TestModifier<Double>()
            }
            
            if true {
                TestModifier<String>()
            }
            
            if false {
                TestModifier<Never>()
            }
        }
        
        #expect(
            modifier is _TupleModifier<
            _ConditionalModifier<TestModifier<Int>, TestModifier<Never>>,
            _ConditionalModifier<TestModifier<Never>, TestModifier<Double>>,
            _OptionalModifier<TestModifier<String>>,
            _OptionalModifier<TestModifier<Never>>,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier
            >
        )
    }
    
    @Test func buildLimitedAvailability() {
        let modifier = build {
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestModifier<Never>()
            }else {
                TestModifier<Int>()
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestModifier<Double>()
            }else {
                TestModifier<Never>()
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestModifier<String>()
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestModifier<Never>()
            }
        }
        
        #expect(
            modifier is _TupleModifier<
            _ConditionalModifier<TestModifier<Never>, TestModifier<Int>>,
            _ConditionalModifier<TestModifier<Double>, TestModifier<Never>>,
            _OptionalModifier<TestModifier<String>>,
            _OptionalModifier<TestModifier<Never>>,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier,
            EmptyModifier
            >
        )
    }
    
    @Test func modifiersModifyingURLRequest() throws {
        let modifier = build {
            if true {
                TestModifier<String>(header: ("String", "true"))
            }else {
                TestModifier<Never>(header: ("Never", "true"))
            }
            
            if false {
                TestModifier<Never>(header: ("Never", "false"))
            }else {
                TestModifier<Float>(header: ("Float", "true"))
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestModifier<Double>(header: ("Double", "false"))
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestModifier<Int64>(header: ("Int64", "true"))
            }
            
            TestModifier<Int>(header: ("Int", "true"))
        }
        
        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        let modified = try modifier.modifying(urlRequest)
        
        #expect(modified.allHTTPHeaderFields?.count == 4)
        #expect(modified.allHTTPHeaderFields?["String"] == "true")
        #expect(modified.allHTTPHeaderFields?["Int"] == "true")
        #expect(modified.allHTTPHeaderFields?["Float"] == "true")
        #expect(modified.allHTTPHeaderFields?["Int64"] == "true")
    }
}

extension ModifiersBuilderTests {
    @RequestModifier struct TestModifier<T> {
        var header = (key: "", value: "")
        func modifying(
            _ request: consuming URLRequest
        ) throws(NetworkingError) -> URLRequest {
            var modified = request
            modified.setValue(header.value, forHTTPHeaderField: header.key)
            return modified
        }
    }
}

    
extension Tag {
    @Tag internal static var resultBuilders: Self
}
