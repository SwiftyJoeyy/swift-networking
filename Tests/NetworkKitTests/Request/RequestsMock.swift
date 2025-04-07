//
//  RequestsMock.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
@testable import NetworkKit

struct DummyRequest: Request {
    typealias Contents = Never
    var _modifiers = [any RequestModifier]()
    
    var allModifiers: [any RequestModifier] {
        return _modifiers
    }
}

struct RequestModifierStub: RequestModifier {
    var headers: [String: String]?
    func modifying(
        _ request: consuming URLRequest,
        with configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        if let headers {
            let merged = (request.allHTTPHeaderFields ?? [:])
                .merging(headers) { _, new in
                    return new
                }
            request.allHTTPHeaderFields = merged
        }
        return request
    }
}

struct NestedRequest: Request {
    typealias Contents = Never
    
    var _modifiers = [any RequestModifier]()
    
    var allModifiers: [any RequestModifier] {
        return _modifiers
    }
    
    public func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        let configs = copy configurations
        var request = URLRequest(url: configs.url!)
        
        for component in _modifiers {
            request = try component.modifying(
                consume request,
                with: configurations
            )
        }
        return request
    }
}

@Request struct MockRequest<T: Request> {
    var transform: (NestedRequest) -> T
    
    var request: T {
        transform(NestedRequest())
    }
}

extension MockRequest where T == NestedRequest {
    init() {
        self.transform = { req in
            req
        }
    }
}

@Request("SomeID") struct MacrosRequest {
    @Header var header = "value"
    @Parameter var parameter = "value"
    var request: some Request {
        NestedRequest()
    }
}

