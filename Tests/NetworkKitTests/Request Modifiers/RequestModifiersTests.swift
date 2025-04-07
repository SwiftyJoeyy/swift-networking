//
//  RequestModifiersTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Test func applyingHTTPMethodToURLRequest() throws {
    let method = RequestMethod.post
    let urlRequest = URLRequest(url: URL(string: "example.com")!)
    
    let modifier = HTTPMethodRequestModifier(method)
    let newRequest = try modifier.modifying(
        urlRequest,
        with: ConfigurationValues.mock
    )
    
    #expect(newRequest.httpMethod == method.rawValue)
}

@Test func applyingTHTTPMethodModifierToRequest() throws {
    let request = DummyRequest().method(.get)
    
    #expect(request.allModifiers.contains(where: {$0 is HTTPMethodRequestModifier}))
}


@Test func applyingTimeoutIntervalToURLRequest() throws {
    let timeout: TimeInterval = 1000
    let urlRequest = URLRequest(url: URL(string: "example.com")!)
    
    let modifier = TimeoutRequestModifier(timeout)
    let newRequest = try modifier.modifying(
        urlRequest,
        with: ConfigurationValues.mock
    )
    
    #expect(newRequest.timeoutInterval == timeout)
}

@Test func applyingTimeoutIntervalModifierToRequest() throws {
    let request = DummyRequest().timeout(90)
    
    #expect(request.allModifiers.contains(where: {$0 is TimeoutRequestModifier}))
}


@Test(.serialized, arguments: [
    URLRequest.CachePolicy.useProtocolCachePolicy,
    URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
    URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
    URLRequest.CachePolicy.reloadRevalidatingCacheData,
    URLRequest.CachePolicy.returnCacheDataDontLoad,
    URLRequest.CachePolicy.returnCacheDataElseLoad,
    URLRequest.CachePolicy.reloadIgnoringCacheData
])
func applyingCachePolityToURLRequest(policy: URLRequest.CachePolicy) throws {
    let urlRequest = URLRequest(url: URL(string: "example.com")!)
    
    let modifier = CachePolicyRequestModifier(policy)
    let newRequest = try modifier.modifying(
        urlRequest,
        with: ConfigurationValues.mock
    )
    
    #expect(newRequest.cachePolicy == policy)
}

@Test func applyingCachePolicyModifierToRequest() throws {
    let request = DummyRequest().cachePolicy(.reloadIgnoringCacheData)
    
    #expect(request.allModifiers.contains(where: {$0 is CachePolicyRequestModifier}))
}
