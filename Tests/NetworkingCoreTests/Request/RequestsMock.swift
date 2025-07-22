//
//  RequestsMock.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
@testable import NetworkingCore

struct DummyRequest: Request {
    var request: Never {
        fatalError()
    }
}

struct MockRequest: Request {
    struct Contents: Request {
        let id = "NestedRequest"
        
        var request: Never {
            fatalError()
        }
        
        func _makeURLRequest(
            with configurations: ConfigurationValues
        ) throws(NetworkingError) -> URLRequest {
            var request = URLRequest(url: URL(string: "https://example.com")!)
            request.httpMethod = "GET"
            let text = configurations[MockConfigKey.self]
            request.setValue(text, forHTTPHeaderField: "ConfigHeader")
            return request
        }
    }
    
    var request = Contents()
}

struct MockConfigKey: ConfigurationKey {
    static let defaultValue: String = "Config"
}

@RequestModifier struct ConfiguredModifier {
    @Configurations private var configurations
    func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        let text = configurations[MockConfigKey.self]
        request.setValue(text, forHTTPHeaderField: "ConfigHeader")
        return request
    }
}
