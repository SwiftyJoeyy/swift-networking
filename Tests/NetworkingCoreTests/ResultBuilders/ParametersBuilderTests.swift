//
//  ParametersBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@_spi(Internal) @testable import NetworkingCore

@Suite(.tags(.resultBuilders))
struct ParametersBuilderTests {
// MARK: - Functions
    private func buildParam(
        @ParametersBuilder _ action: () -> some RequestParameter
    ) -> some RequestParameter {
        return action()
    }
    private func build(
        @ParametersBuilder _ action: () -> some RequestParameter
    ) -> [URLQueryItem] {
        return buildParam(action).parameters
    }
    
// MARK: - Tests
    @Test func buildBlockWithNoParameters() {
        let params = build { }
        
        #expect(params == [])
    }
    
    @Test func buildBlockWithOneParameter() {
        let params = build {
            TestParameter(name: "A", value: "1")
        }
        
        let expectedParams = [
            URLQueryItem(name: "A", value: "1")
        ]
        #expect(params == expectedParams)
    }
    
    @Test func buildBlockWithMultipleParameters() {
        do {
            let params = build {
                TestParameter(name: "A", value: "1")
                TestParameter(name: "B", value: "2")
            }
            
            let expectedParams = [
                URLQueryItem(name: "A", value: "1"),
                URLQueryItem(name: "B", value: "2")
            ]
            #expect(params == expectedParams)
        }
        
        do {
            let params = build {
                TestParameter(name: "A", value: "1")
                TestParameter(name: "B", value: "2")
                TestParameter(name: "C", value: "3")
                TestParameter(name: "D", value: "4")
                TestParameter(name: "E", value: "5")
                TestParameter(name: "F", value: "6")
                TestParameter(name: "G", value: "7")
                TestParameter(name: "H", value: "8")
                TestParameter(name: "I", value: "9")
                TestParameter(name: "J", value: "10")
            }
            
            let expectedParams = [
                URLQueryItem(name: "A", value: "1"),
                URLQueryItem(name: "B", value: "2"),
                URLQueryItem(name: "C", value: "3"),
                URLQueryItem(name: "D", value: "4"),
                URLQueryItem(name: "E", value: "5"),
                URLQueryItem(name: "F", value: "6"),
                URLQueryItem(name: "G", value: "7"),
                URLQueryItem(name: "H", value: "8"),
                URLQueryItem(name: "I", value: "9"),
                URLQueryItem(name: "J", value: "10"),
            ]
            #expect(params == expectedParams)
        }
    }

    @Test func buildOptionalParameter() {
        let valueParam: TestParameter? = TestParameter(name: "Opt", value: "Value")
        let optionalParam: TestParameter? = nil
        let params = build {
            if let valueParam {
                valueParam
            }
            if let optionalParam {
                optionalParam
            }
        }
        
        let expectedParams = [URLQueryItem(name: "Opt", value: "Value")]
        #expect(params == expectedParams)
    }
    
    @Test func buildConditionalHeaders() {
        let params = build {
            if true {
                TestParameter(name: "A", value: "true")
            }else {
                TestParameter(name: "A", value: "false")
            }
            
            if false {
                TestParameter(name: "B", value: "true")
            }else {
                TestParameter(name: "B", value: "false")
            }
            
            if true {
                TestParameter(name: "C", value: "true")
            }
            
            if false {
                TestParameter(name: "D", value: "false")
            }
        }
        
        let expectedParams = [
            URLQueryItem(name: "A", value: "true"),
            URLQueryItem(name: "B", value: "false"),
            URLQueryItem(name: "C", value: "true")
        ]
        #expect(params == expectedParams)
    }
    
    @Test func buildLimitedAvailability() {
        let params = build {
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestParameter(name: "A", value: "available")
            }else {
                TestParameter(name: "A", value: "unavailable")
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestParameter(name: "B", value: "available")
            }else {
                TestParameter(name: "B", value: "unavailable")
            }
            
            if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0, *) {
                TestParameter(name: "C", value: "available")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestParameter(name: "D", value: "unavailable")
            }
        }
        
        let expectedParams = [
            URLQueryItem(name: "A", value: "unavailable"),
            URLQueryItem(name: "B", value: "available"),
            URLQueryItem(name: "C", value: "available")
        ]
        #expect(params == expectedParams)
    }
    
    @Test func paramsModifyingURLRequest() throws {
        let param = buildParam {
            if true {
                TestParameter(name: "D", value: "val")
            }else {
                TestParameter(name: "A", value: "val")
            }
            
            if false {
                TestParameter(name: "E", value: "val")
            }else {
                TestParameter(name: "F", value: "val")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestParameter(name: "C", value: "val")
            }
            
            TestParameter(name: "B", value: "val")
        }
        
        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        let modified = try param.modifying(urlRequest)
        
        let finalURL = try #require(modified.url)
        let components = try #require(
            URLComponents(
                url: finalURL,
                resolvingAgainstBaseURL: false
            )
        )
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.count == 3)
        #expect(queryItems.contains(URLQueryItem(name: "D", value: "val")))
        #expect(queryItems.contains(URLQueryItem(name: "B", value: "val")))
        #expect(queryItems.contains(URLQueryItem(name: "F", value: "val")))
    }
    
    @Test func parameterDescription() throws {
        let param = buildParam {
            if true {
                TestParameter(name: "D", value: "val")
            }else {
                TestParameter(name: "A", value: "val")
            }
            
            if false {
                TestParameter(name: "E", value: "val")
            }else {
                TestParameter(name: "F", value: "val")
            }
            
            if #unavailable(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, macCatalyst 15.0) {
                TestParameter(name: "C", value: "val")
            }
            
            TestParameter(name: "B", value: "val")
        }
        
        let result = param.description
        
        #expect(result.contains("D : val"))
        #expect(result.contains("B : val"))
        #expect(result.contains("F : val"))
        #expect(!result.contains("C : val"))
        #expect(!result.contains("A : val"))
        #expect(!result.contains("E : val"))
    }
}

extension ParametersBuilderTests {
    struct TestParameter: RequestParameter {
        let name: String
        let value: String?
        
        var parameters: [URLQueryItem] {
            return [URLQueryItem(name: name, value: value)]
        }
    }
}
