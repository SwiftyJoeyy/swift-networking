//
//  RequestParametersTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkKit

/// Suite for testing the functionality of ``RequestParameter``.
@Suite(.tags(.requestModifiers, .parameters))
struct RequestParametersTests {
// MARK: - Properties
    private let configurations = ConfigurationValues.mock
    
    /// ``URL`` for testing.
    private let url = URL(string: "example.com")!
    
    /// ``URL`` with an existing parameter for testing.
    private let urlWithParameters = URL(string: "example.com?testing=hello")!
    
    /// Array of parameters to test.
    private let parameters = [
        URLQueryItem(name: "test1", value: "1"),
        URLQueryItem(name: "test2", value: "2"),
        URLQueryItem(name: "test3", value: "3")
    ]
    
    /// Array of parameters that share the same name to test.
    private let arrayParameters = [
        URLQueryItem(name: "test", value: "1"),
        URLQueryItem(name: "test", value: "2"),
        URLQueryItem(name: "test", value: "3")
    ]
    
// MARK: - Private Functions
    /// Encode paramters into a ``URL``.
    private func encode(url: URL, parameters: [URLQueryItem]) throws -> String? {
        let collection = ParametersGroup(parameters)
        
        let request = URLRequest(url: url)
        let modifiedRequest = try collection.modifying(request, with: configurations)
        
        return modifiedRequest.url?.absoluteString
    }
    
// MARK: - Parameter Tests
    /// Checks that ``Parameter`` is correctly converted to ``[URLQueryItem]``.
    @Test func convertParameterToURLQueryItem() {
        let parameter = Parameter("testing", value: "Hii")
        let expectedItems = [URLQueryItem(name: "testing", value: "Hii")]
        
        #expect(parameter.parameters == expectedItems)
    }
    
    /// Checks that ``Parameter`` with an array value is correctly converted to ``[URLQueryItem]``.
    @Test func convertParameterWithArrayToURLQueryItem() {
        let parameter = Parameter("testing", values: ["1", "2"])
        let expectedItems = [
            URLQueryItem(name: "testing", value: "1"),
            URLQueryItem(name: "testing", value: "2")
        ]
        
        #expect(parameter.parameters == expectedItems)
    }
    
// MARK: - ParametersGroup Tests
    /// Checks that ``ParametersGroup`` is correctly converted to ``[URLQueryItem]``.
    @Test func convertParametersGroupToURLQueryItem() {
        let group = ParametersGroup {
            Parameter("testing", value: "Hii")
            Parameter("testing2", value: "Hii2")
        }
        
        let expectedItems = [
            URLQueryItem(name: "testing", value: "Hii"),
            URLQueryItem(name: "testing2", value: "Hii2")
        ]
        
        #expect(group.parameters == expectedItems)
    }
    
    /// Checks that ``ParametersGroup`` with an array value is correctly converted to ``[URLQueryItem]``.
    @Test func convertParametersGroupWithArrayToURLQueryItem() {
        let group = ParametersGroup {
            Parameter("testing", value: "Hii")
            Parameter("testing2", values: ["1", "2"])
        }
        
        let expectedItems = [
            URLQueryItem(name: "testing", value: "Hii"),
            URLQueryItem(name: "testing2", value: "1"),
            URLQueryItem(name: "testing2", value: "2")
        ]
        
        #expect(group.parameters == expectedItems)
    }
    
// MARK: - URL Tests
    /// Checks that parameters are correcly encoded in to a ``URL``.
    @Test func encodingQueryParameters() throws {
        let expectedURL = "example.com?test1=1&test2=2&test3=3"
        let actualURL = try encode(url: url, parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL``.
    @Test func encodingQueryParametersArray() throws {
        let expectedURL = "example.com?test=1&test=2&test=3"
        let actualURL = try encode(url: url, parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
// MARK: - URL With Path Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with a path.
    @Test func encodingQueryParametersToURLWithPath() throws {
        let expectedURL = "example.com/path?test1=1&test2=2&test3=3"
        let actualURL = try encode(url: url.appending(path: "path"), parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with a path.
    @Test func encodingQueryParametersArrayToURLWithPath() throws {
        let expectedURL = "example.com/path?test=1&test=2&test=3"
        let actualURL = try encode(url: url.appending(path: "path"), parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
// MARK: - URL With Parameters Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with existing paramters.
    @Test func encodingQueryParametersToURLWithParameters() throws {
        let expectedURL = "example.com?testing=hello&test1=1&test2=2&test3=3"
        let actualURL = try encode(url: urlWithParameters, parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with existing paramters.
    @Test func encodingQueryParametersArrayToURLWithParameters() throws {
        let expectedURL = "example.com?testing=hello&test=1&test=2&test=3"
        let actualURL = try encode(url: urlWithParameters, parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
// MARK: - URL With Parameters & Path Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with a path & existing paramters.
    @Test func encodingQueryParametersToURLWithParametersAndPath() throws {
        let expectedURL = "example.com/path?testing=hello&test1=1&test2=2&test3=3"
        let actualURL = try encode(
            url: urlWithParameters.appending(path: "path"),
            parameters: parameters
        )
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with a path & existing paramters.
    @Test func encodingQueryParametersArrayToURLWithParametersAndPath() throws {
        let expectedURL = "example.com/path?testing=hello&test=1&test=2&test=3"
        let actualURL = try encode(
            url: urlWithParameters.appending(path: "path"),
            parameters: arrayParameters
        )
        
        #expect(actualURL == expectedURL)
    }
}

// MARK: - ParametersGroup Tests
extension RequestParametersTests {
    @Test func initWithPlainURLQueryItems() {
        let expectedItems = [
            URLQueryItem(name: "q", value: "swift"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let group = ParametersGroup(expectedItems)
        
        #expect(group.parameters == expectedItems)
    }
    
    @Test func initWithOptionalURLQueryItems() {
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
    
    @Test func initWithRequestParameterArray() {
        let param1 = DummyParameter(
            parameters: [URLQueryItem(name: "filter", value: "active")]
        )
        let param2 = DummyParameter(
            parameters: [URLQueryItem(name: "sort", value: "desc")]
        )
        
        let group = ParametersGroup([param1, param2])
        
        let expectedItems = [
            URLQueryItem(name: "filter", value: "active"),
            URLQueryItem(name: "sort", value: "desc")
        ]
        #expect(group.parameters == expectedItems)
    }
    
    @Test func initWithBuilder() {
        let group = ParametersGroup {
            ParametersGroup([
                URLQueryItem(name: "country", value: "US")
            ])
            DummyParameter(
                parameters: [URLQueryItem(name: "sort", value: "desc")]
            )
        }
        
        let expectedItems = [
            URLQueryItem(name: "country", value: "US"),
            URLQueryItem(name: "sort", value: "desc")
        ]
        #expect(group.parameters == expectedItems)
    }
    
    struct DummyParameter: RequestParameter {
        let parameters: [URLQueryItem]
    }
}

// MARK: - Modifier Tests
extension RequestParametersTests {
    @Test func appliesAdditionalParametersModifierToRequest() {
        let request = DummyRequest()
            .additionalParameters {
                DummyParameter(
                    parameters: [URLQueryItem(name: "sort", value: "desc")]
                )
            }
        
        #expect(request.allModifiers.contains(where: {$0 is ParametersGroup}))
    }
}

extension Tag {
    @Tag internal static var parameters: Self
}
