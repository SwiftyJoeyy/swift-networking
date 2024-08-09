//
//  RequestParametersCollectionTests.swift
//
//
//  Created by Joe Maghzal on 30/05/2024.
//

import Testing
import Foundation
@testable import NetworkKit

/// Suite for testing the functionality of ``RequestParametersCollection``.
@Suite(.tags(.parameters))
struct RequestParametersCollectionTests {
//MARK: - Properties
    /// ``URL`` for testing.
    private let url = URL(string: "google.com")!
    
    /// ``URL`` with an existing parameter for testing.
    private let urlWithParameters = URL(string: "google.com?testing=hello")!
    
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
    
//MARK: - Private Functions
    /// Encode paramters into a ``URL``.
    private func encode(url: URL, parameters: [URLQueryItem]) throws -> String? {
        let collection = RequestParametersCollectionStub(parameters: parameters)
        
        let request = URLRequest(url: url)
        let modifiedRequest = try collection.encoding(into: request)
        
        return modifiedRequest.url?.absoluteString
    }
    
//MARK: - URL Tests
    /// Checks that parameters are correcly encoded in to a ``URL``.
    @Test func encodingQueryParameters() throws {
        let expectedURL = "google.com?test1=1&test2=2&test3=3"
        let actualURL = try encode(url: url, parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL``.
    @Test func encodingQueryParametersArray() throws {
        let expectedURL = "google.com?test=1&test=2&test=3"
        let actualURL = try encode(url: url, parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
//MARK: - URL With Path Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with a path.
    @Test func encodingQueryParametersToURLWithPath() throws {
        let expectedURL = "google.com/path?test1=1&test2=2&test3=3"
        let actualURL = try encode(url: url.appending(path: "path"), parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with a path.
    @Test func encodingQueryParametersArrayToURLWithPath() throws {
        let expectedURL = "google.com/path?test=1&test=2&test=3"
        let actualURL = try encode(url: url.appending(path: "path"), parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
//MARK: - URL With Parameters Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with existing paramters.
    @Test func encodingQueryParametersToURLWithParameters() throws {
        let expectedURL = "google.com?testing=hello&test1=1&test2=2&test3=3"
        let actualURL = try encode(url: urlWithParameters, parameters: parameters)
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with existing paramters.
    @Test func encodingQueryParametersArrayToURLWithParameters() throws {
        let expectedURL = "google.com?testing=hello&test=1&test=2&test=3"
        let actualURL = try encode(url: urlWithParameters, parameters: arrayParameters)
        
        #expect(actualURL == expectedURL)
    }
    
//MARK: - URL With Parameters & Path Tests
    /// Checks that parameters are correcly encoded in to a ``URL`` with a path & existing paramters.
    @Test func encodingQueryParametersToURLWithParametersAndPath() throws {
        let expectedURL = "google.com/path?testing=hello&test1=1&test2=2&test3=3"
        let actualURL = try encode(
            url: urlWithParameters.appending(path: "path"),
            parameters: parameters
        )
        
        #expect(actualURL == expectedURL)
    }
    
    /// Checks that parameters with duplicate keys are correcly encoded in to a ``URL`` with a path & existing paramters.
    @Test func encodingQueryParametersArrayToURLWithParametersAndPath() throws {
        let expectedURL = "google.com/path?testing=hello&test=1&test=2&test=3"
        let actualURL = try encode(
            url: urlWithParameters.appending(path: "path"),
            parameters: arrayParameters
        )
        
        #expect(actualURL == expectedURL)
    }
}

//MARK: - RequestParametersCollectionStub
extension RequestParametersCollectionTests {
    /// Stub version of ``RequestParametersCollection``.
    struct RequestParametersCollectionStub: RequestParametersCollection {
        /// Parameters to use for creating a request.
        let parameters: [URLQueryItem]
    }
}
