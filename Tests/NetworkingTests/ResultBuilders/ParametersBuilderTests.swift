//
//  ParametersBuilderTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import Networking

@Suite(.tags(.resultBuilders))
struct ParametersBuilderTests {
    private func build(@ParametersBuilder _ action: () -> ParametersGroup) -> [URLQueryItem] {
        return action().parameters
    }
    
    @Test func buildBlockWithMultipleParameters() {
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

    @Test func buildArray() {
        let paramsArray: [any RequestParameter] = [
            TestParameter(name: "A", value: "1"),
            TestParameter(name: "B", value: "2")
        ]
        let params = build {
            for param in paramsArray {
                param
            }
        }
        
        let expectedParams = [
            URLQueryItem(name: "A", value: "1"),
            URLQueryItem(name: "B", value: "2")
        ]
        #expect(params == expectedParams)
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
            if #available(macOS 16.0, *) {
                TestParameter(name: "A", value: "available")
            }else {
                TestParameter(name: "A", value: "unavailable")
            }
            
            if #available(macOS 12.0, *) {
                TestParameter(name: "B", value: "available")
            }else {
                TestParameter(name: "B", value: "unavailable")
            }
            
            if #available(macOS 12.0, *) {
                TestParameter(name: "C", value: "available")
            }
            
            if #available(macOS 16.0, *) {
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
