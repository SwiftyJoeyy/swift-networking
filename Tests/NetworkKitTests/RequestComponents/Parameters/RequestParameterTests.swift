//
//  RequestParameterTests.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Testing
import Foundation
@testable import NetworkKit

/// Suite for testing the functionality of ``RequestParameter``.
@Suite(.tags(.parameters))
struct RequestParameterTests {
    /// Checks that ``RequestParameter`` is correctly converted to ``[URLQueryItem]``.
    @Test func convertParameterToURLQueryItem() {
        let parameter = RequestParameterStub(key: "testing", value: ["Hii"])
        let expectedItems = [URLQueryItem(name: "testing", value: "Hii")]
        
        #expect(parameter.parameters == expectedItems)
    }
    
    /// Checks that ``RequestParameter`` with an array value is correctly converted to ``[URLQueryItem]``.
    @Test func convertParameterWithArrayToURLQueryItem() {
        let parameter = RequestParameterStub(key: "testing", value: ["1", "2"])
        let expectedItems = [URLQueryItem(name: "testing", value: "1"), URLQueryItem(name: "testing", value: "2")]
        
        #expect(parameter.parameters == expectedItems)
    }
}

//MARK: - RequestParametersCollectionStub
extension RequestParameterTests {
    /// Stub version of ``RequestParametersCollection``.
    struct RequestParameterStub: RequestParameter {
        /// The name of the parameter.
        var key: String
        
        /// The value of the parameter.
        var value: [String?]
    }
}
