//
//  RequestTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Suite(.tags(.request))
struct RequestTests {
    private let configurations = ConfigurationValues.mock
    private let url = URL(string: "example.com")!
    
    @Test func applyingModifierAppendsItToModifiersArray() {
        let request = MockRequest().modifier(RequestModifierStub())
        
        #expect(request._modifiers.contains(where: {$0 is RequestModifierStub}))
        #expect(request.allModifiers.contains(where: {$0 is RequestModifierStub}))
    }
    
    @Test func allModifiersIncludesNestedRequestModifiers() {
        let request = MockRequest { req in
            req.modifier(RequestModifierStub())
        }
        
        #expect(request.allModifiers.contains(where: {$0 is RequestModifierStub}))
        #expect(!request._modifiers.contains(where: {$0 is RequestModifierStub}))
    }
    
    @Test func modifiersIncludesMacroRequestModifiers() {
        let request = MacrosRequest()
        
        #expect(request.allModifiers.contains(where: {$0 is HeadersGroup}))
        #expect(request.allModifiers.contains(where: {$0 is ParametersGroup}))
        
        #expect(request._modifiers.contains(where: {$0 is HeadersGroup}))
        #expect(request._modifiers.contains(where: {$0 is ParametersGroup}))
    }
    
    @Test func applyingModifierToMacroRequestAppendsItToModifiersArray() {
        let request = MacrosRequest().modifier(RequestModifierStub())
        
        #expect(request.allModifiers.contains(where: {$0 is HeadersGroup}))
        #expect(request.allModifiers.contains(where: {$0 is ParametersGroup}))
        #expect(request.allModifiers.contains(where: {$0 is RequestModifierStub}))
        
        #expect(request._modifiers.contains(where: {$0 is HeadersGroup}))
        #expect(request._modifiers.contains(where: {$0 is ParametersGroup}))
        #expect(request._modifiers.contains(where: {$0 is RequestModifierStub}))
    }
    
    @Test func allModifiersAreAppliedWhenBuildingURLRequest() throws {
        let request = MockRequest { req in
            req.modifier(RequestModifierStub(headers: ["nested": "value"]))
        }.modifier(RequestModifierStub(headers: ["out": "value"]))
        
        let urlRequest = try request._makeURLRequest(configurations)
        let headers = urlRequest.allHTTPHeaderFields
        
        #expect(headers?["nested"] == "value")
        #expect(headers?["out"] == "value")
    }
    
    @Test func requestIDAppliedFromMacro() throws {
        let request = MacrosRequest()
        
        #expect(request.id == "SomeID")
    }
    
    @Test func requestWithoutID() throws {
        let request = NestedRequest()
        
        #expect(request.id == String(describing: NestedRequest.self))
    }
}
