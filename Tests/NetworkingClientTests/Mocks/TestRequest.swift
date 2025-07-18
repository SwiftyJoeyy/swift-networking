//
//  TestRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 6/2/25.
//

import Foundation
@testable import NetworkingCore

struct TestRequest: Request {
    @Configurations private var configurations
    var id = "TestRequest"
    var request: Never {
        fatalError()
    }
    
    func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws(NetworkingError) -> URLRequest {
        return URLRequest(url: configurations.baseURL ?? URL(string: "fallback.com")!)
    }
    func _accept(_ values: ConfigurationValues) {
        _configurations._accept(values)
    }
}

extension Request {
    func testID(_ id: String) -> some Request {
        modifier(Header("test-id", value: id))
    }
}
