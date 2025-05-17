//
//  RequestModifiersTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Test(.tags(.requestModifiers)) func applyingHTTPMethodToURLRequest() throws {
    let method = RequestMethod.post
    let urlRequest = URLRequest(url: URL(string: "example.com")!)
    
    let modifier = HTTPMethodRequestModifier(method)
    let newRequest = try modifier.modifying(
        urlRequest,
        with: ConfigurationValues.mock
    )
    
    #expect(newRequest.httpMethod == method.rawValue)
}

@Test(.tags(.requestModifiers)) func applyingTHTTPMethodModifierToRequest() throws {
    let request = DummyRequest().method(.get)
    
    let modified = getModified(request, DummyRequest.self, HTTPMethodRequestModifier.self)
    #expect(modified != nil)
}


@Test(.tags(.requestModifiers)) func applyingTimeoutIntervalToURLRequest() throws {
    let timeout: TimeInterval = 1000
    let urlRequest = URLRequest(url: URL(string: "example.com")!)
    
    let modifier = TimeoutRequestModifier(timeout)
    let newRequest = try modifier.modifying(
        urlRequest,
        with: ConfigurationValues.mock
    )
    
    #expect(newRequest.timeoutInterval == timeout)
}

@Test(.tags(.requestModifiers)) func applyingTimeoutIntervalModifierToRequest() throws {
    let request = DummyRequest().timeout(90)
    
    let modified = getModified(request, DummyRequest.self, TimeoutRequestModifier.self)
    #expect(modified != nil)
}


@Test(.serialized, .tags(.requestModifiers), arguments: [
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

@Test(.tags(.requestModifiers)) func applyingCachePolicyModifierToRequest() throws {
    let request = DummyRequest().cachePolicy(.reloadIgnoringCacheData)
    
    let modified = getModified(request, DummyRequest.self, CachePolicyRequestModifier.self)
    #expect(modified != nil)
}

extension Tag {
    @Tag internal static var requestModifiers: Self
}
