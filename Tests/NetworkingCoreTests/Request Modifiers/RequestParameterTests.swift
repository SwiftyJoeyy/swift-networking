//
//  RequestParameterTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@_spi(Internal) @testable import NetworkingCore

/// Suite for testing the functionality of ``RequestParameter``.
@Suite(.tags(.requestModifiers, .parameters))
struct RequestParameterTests {
// MARK: - Properties
    /// ``URL`` for testing.
    private let url = URL(string: "example.com")!
    
    /// ``URL`` with an existing parameter for testing.
    private let urlWithParameters = URL(string: "example.com?testing=hello")!
    
// MARK: - Parameter Tests
    @Test func singleValueParameterCreatesCorrectQueryItem() {
        let param = Parameter("device", value: "iPhone")
        
        #expect(param.name == "device")
        #expect(param.values == ["iPhone"])
        #expect(param.parameters == [URLQueryItem(name: "device", value: "iPhone")])
    }
    
    @Test func nilValueParameterDoesCreatesCorrectQueryItem() {
        do {
            let value: String? = nil
            let param = Parameter("device", value: value)
            
            #expect(param.name == "device")
            #expect(param.parameters.isEmpty)
        }
        
        do {
            let values: [String]? = nil
            let param = Parameter("device", values: values)
            
            #expect(param.name == "device")
            #expect(param.parameters.isEmpty)
        }
    }
    
    @Test func multipleValueParameterCreatesMultipleQueryItems() {
        let param = Parameter("lang", values: ["en", "fr", nil])
        #expect(param.parameters.count == 2)
        #expect(param.parameters[0] == URLQueryItem(name: "lang", value: "en"))
        #expect(param.parameters[1] == URLQueryItem(name: "lang", value: "fr"))
    }
    
    @Test func modifyingURLRequestWithNilURL() throws {
        let param = Parameter("search", value: "swift")
        var request = URLRequest(url: url)
        request.url = nil
        let modified = try param.modifying(request)
        
        #expect(modified == request)
    }
    
    @Test func modifyingURLRequestAppendsQueryParameters() throws {
        let param = Parameter("search", value: "swift")
        let request = URLRequest(url: url)
        let modified = try param.modifying(request)
        
        let finalURL = try #require(modified.url)
        let components = try #require(
            URLComponents(
                url: finalURL,
                resolvingAgainstBaseURL: false
            )
        )
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "search", value: "swift")))
    }
    
    @Test func modifyingURLRequestWithExistingParametersAppendsQueryParameters() throws {
        let param = Parameter("search", value: "swift")
        let request = URLRequest(url: urlWithParameters)
        let modified = try param.modifying(request)
        
        let finalURL = try #require(modified.url)
        let components = try #require(
            URLComponents(
                url: finalURL,
                resolvingAgainstBaseURL: false
            )
        )
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "search", value: "swift")))
        #expect(queryItems.contains(URLQueryItem(name: "testing", value: "hello")))
    }
    
    @Test func parameterWithNonStringValueConvertedToString() {
        let name = "name"
        do {
            let expectedParam = Parameter(name, value: "1")
            let param = Parameter(name, value: 1)
            #expect(param == expectedParam)
        }
        do {
            let expectedParam = Parameter(name, value: "1.0")
            let param = Parameter(name, value: 1.0)
            #expect(param == expectedParam)
        }
        do {
            let expectedParam = Parameter(name, value: "true")
            let param = Parameter(name, value: true)
            #expect(param == expectedParam)
        }
    }
    
    @Test func parameterWithNonStringNilValueConvertedToString() {
        let name = "name"
        let stringValue: String? = nil
        let expectedParam = Parameter(name, value: stringValue)
        do {
            let value: Int? = nil
            let param = Parameter(name, value: value)
            #expect(param == expectedParam)
        }
        do {
            let value: Double? = nil
            let param = Parameter(name, value: value)
            #expect(param == expectedParam)
        }
        do {
            let value: Bool? = nil
            let param = Parameter(name, value: value)
            #expect(param == expectedParam)
        }
    }
    
    @Test func parameterWithMultipleNonStringValuesConvertedToString() {
        let name = "name"
        do {
            let expectedParam = Parameter(name, values: ["1", "23", nil])
            let param = Parameter(name, values: [1, 23, nil])
            #expect(param == expectedParam)
        }
        do {
            let expectedParam = Parameter(name, values: ["1.0", "2.3", nil])
            let param = Parameter(name, values: [1.0, 2.3, nil])
            #expect(param == expectedParam)
        }
        do {
            let expectedParam = Parameter(name, values: ["true", "false", nil])
            let param = Parameter(name, values: [true, false, nil])
            #expect(param == expectedParam)
        }
    }
    
    @Test func parameterWithMultipleNonStringNilValuesConvertedToString() {
        let name = "name"
        let stringValues: [String]? = nil
        let expectedParam = Parameter(name, values: stringValues)
        do {
            let values: [Int]? = nil
            let param = Parameter(name, values: values)
            #expect(param == expectedParam)
        }
        do {
            let values: [Double]? = nil
            let param = Parameter(name, values: values)
            #expect(param == expectedParam)
        }
        do {
            let values: [Bool]? = nil
            let param = Parameter(name, values: values)
            #expect(param == expectedParam)
        }
    }
}

// MARK: - ParametersGroup Tests
extension RequestParameterTests {
    @Test func groupInitWithPlainURLQueryItems() {
        let expectedItems = [
            URLQueryItem(name: "q", value: "swift"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let group = ParametersGroup(expectedItems)
        
        #expect(group.parameters == expectedItems)
    }
    
    @Test func groupInitWithOptionalURLQueryItems() {
        let items: [URLQueryItem?] = [
            URLQueryItem(name: "lang", value: "en"),
            nil,
            URLQueryItem(name: "page", value: "1")
        ]
        let group = ParametersGroup(items)
        
        let expectedItems = [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "page", value: "1")
        ]
        #expect(group.parameters == expectedItems)
    }
    
    @Test func groupInitWithParametersBuilder() {
        let group = ParametersGroup {
            DummyParameter(parameters: [URLQueryItem(name: "lang", value: "en")])
            DummyParameter(parameters: [URLQueryItem(name: "page", value: "1")])
        }
        
        let expectedItems = [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "page", value: "1")
        ]
        #expect(group.parameters == expectedItems)
    }
    
    @Test func modifyingURLRequestWithGroupAddsAllItems() throws {
        let group = ParametersGroup([
            URLQueryItem(name: "x", value: "1"),
            URLQueryItem(name: "y", value: "2")
        ])
        let request = URLRequest(url: url)
        let modified = try group.modifying(request)
        
        let finalURL = try #require(modified.url)
        let components = try #require(
            URLComponents(url: finalURL, resolvingAgainstBaseURL: false)
        )
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "x", value: "1")))
        #expect(queryItems.contains(URLQueryItem(name: "y", value: "2")))
    }
    
    @Test func modifyingURLRequestWithExisitingParametersWithGroupAddsAllItems() throws {
        let group = ParametersGroup([
            URLQueryItem(name: "x", value: "1"),
            URLQueryItem(name: "y", value: "2")
        ])
        let request = URLRequest(url: urlWithParameters)
        let modified = try group.modifying(request)
        
        let finalURL = try #require(modified.url)
        let components = try #require(
            URLComponents(
                url: finalURL,
                resolvingAgainstBaseURL: false
            )
        )
        let queryItems = try #require(components.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "x", value: "1")))
        #expect(queryItems.contains(URLQueryItem(name: "y", value: "2")))
        #expect(queryItems.contains(URLQueryItem(name: "testing", value: "hello")))
    }
}

// MARK: - Description Tests
extension RequestParameterTests {
    @Test func descriptionIsEmptyForNoParameters() {
        let param = DummyParameter(parameters: [])
        let result = param.description
        
        #expect(result.contains("DummyParameter = []"))
    }
    
    @Test func testDescriptionContainsParameters() {
        let param = DummyParameter(parameters: [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "page", value: "3"),
            URLQueryItem(name: "font", value: nil)
        ])
        let result = param.description
        
        #expect(result.contains("lang : en"))
        #expect(result.contains("page : 3"))
        #expect(result.contains("font : nil"))
    }
}

// MARK: - Modifier Tests
extension RequestParameterTests {
    @Test func appliesParametersModifierToRequest() {
        let parameter = DummyParameter(
            parameters: [URLQueryItem(name: "sort", value: "desc")]
        )
        do {
            let request = DummyRequest()
                .appendingParameters {
                    parameter
                }
            
            let modified = getModified(request, DummyRequest.self, DummyParameter.self)
            #expect(modified?.modifier.parameters == parameter.parameters)
        }
        
        do {
            let request = DummyRequest()
                .appendingParameter(parameter)
            
            let modified = getModified(request, DummyRequest.self, DummyParameter.self)
            #expect(modified?.modifier.parameters == parameter.parameters)
        }
    }
    
    @Test func appliesParameterModifierWithSingleValueToRequestUsingOverload() {
        let parameter = (name: "A", value: "1")
        let request = DummyRequest()
            .appendingParameter(parameter.name, value: parameter.value)
        
        let modifiedRequest = getModified(request, DummyRequest.self, Parameter.self)
        let expectedParams = [
            URLQueryItem(name: parameter.name, value: parameter.value)
        ]
        #expect(modifiedRequest?.modifier.parameters == expectedParams)
    }
    
    @Test func appliesParameterModifierWithArrayValueToRequestUsingOverload() {
        let parameter = (name: "A", values: ["1", "2"])
        let request = DummyRequest()
            .appendingParameter(parameter.name, values: parameter.values)
        
        let modifiedRequest = getModified(request, DummyRequest.self, Parameter.self)
        let expectedParams = parameter.values.map { value in
            URLQueryItem(name: parameter.name, value: value)
        }
        #expect(modifiedRequest?.modifier.parameters == expectedParams)
    }
    
    struct DummyParameter: RequestParameter {
        let parameters: [URLQueryItem]
    }
}

extension Tag {
    @Tag internal static var parameters: Self
}
