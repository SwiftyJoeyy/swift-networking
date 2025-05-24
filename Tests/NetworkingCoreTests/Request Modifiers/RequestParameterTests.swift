//
//  RequestParameterTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkingCore

/// Suite for testing the functionality of ``RequestParameter``.
@Suite(.tags(.requestModifiers, .parameters))
struct RequestParameterTests {
// MARK: - Properties
    private let configurations = ConfigurationValues.mock
    
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
    
    @Test func multipleValueParameterCreatesMultipleQueryItems() {
        let param = Parameter("lang", values: ["en", "fr", nil])
        #expect(param.parameters.count == 3)
        #expect(param.parameters[0] == URLQueryItem(name: "lang", value: "en"))
        #expect(param.parameters[1] == URLQueryItem(name: "lang", value: "fr"))
        #expect(param.parameters[2] == URLQueryItem(name: "lang", value: nil))
    }
    
    @Test func modifyingURLRequestAppendsQueryParameters() throws {
        let param = Parameter("search", value: "swift")
        let request = URLRequest(url: url)
        let modified = try param.modifying(request, with: configurations)
        
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
        let modified = try param.modifying(request, with: configurations)
        
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
        let modified = try group.modifying(request, with: configurations)
        
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
        let modified = try group.modifying(request, with: configurations)
        
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
            URLQueryItem(name: "font", value: "nil")
        ])
        let result = param.description
        
        #expect(result.contains("lang : en"))
        #expect(result.contains("page : 3"))
        #expect(result.contains("font : nil"))
    }
}

// MARK: - Modifier Tests
extension RequestParameterTests {
    @Test func appliesAdditionalParametersModifierToRequest() {
        do {
            let request = DummyRequest()
                .appendingParameters {
                    DummyParameter(
                        parameters: [URLQueryItem(name: "sort", value: "desc")]
                    )
                }
            
            let modified = getModified(request, DummyRequest.self, DummyParameter.self)
            #expect(modified != nil)
        }
        
        do {
            let request = DummyRequest()
                .appendingParameter(
                    DummyParameter(
                        parameters: [URLQueryItem(name: "sort", value: "desc")]
                    )
                )
            
            let modified = getModified(request, DummyRequest.self, DummyParameter.self)
            #expect(modified != nil)
        }
    }
    
    struct DummyParameter: RequestParameter {
        let parameters: [URLQueryItem]
    }
}

extension Tag {
    @Tag internal static var parameters: Self
}
