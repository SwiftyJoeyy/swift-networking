//
//  URLSessionConfigurationExtensionTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@_spi(Internal) @testable import NetworkingCore

@Suite(.tags(.utilities))
struct URLSessionConfigurationExtensionTests {
    private let configuration = URLSessionConfiguration.default
    @Test func settingURLCache() {
        let cache = URLCache(memoryCapacity: 512_000, diskCapacity: 1_024_000)
        let config = configuration.urlCache(cache)
        
        #expect(config.urlCache == cache)
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
    func settingRequestCachePolicy(policy: URLRequest.CachePolicy) {
        let config = configuration.requestCachePolicy(policy)
        
        #expect(config.requestCachePolicy == policy)
    }
    
    @Test func settingTimeoutIntervalForRequest() {
        let interval: TimeInterval = 30
        let config = configuration.timeoutIntervalForRequest(interval)
        
        #expect(config.timeoutIntervalForRequest == interval)
    }
    
    @Test func settingTimeoutIntervalForResource() {
        let interval: TimeInterval = 60
        let config = configuration.timeoutIntervalForResource(interval)
        
        #expect(config.timeoutIntervalForResource == interval)
    }
    
    @Test func settingHTTPMaximumConnectionsPerHost() {
        let connections = 5
        let config = configuration.httpMaximumConnectionsPerHost(connections)
        
        #expect(config.httpMaximumConnectionsPerHost == connections)
    }
    
    @Test func settingWaitForConnectivity() {
        let waitConnectivity = true
        
        let config = configuration.waitForConnectivity(waitConnectivity)
        
        #expect(config.waitsForConnectivity == waitConnectivity)
    }
    
    @Test func settingsHeaders() throws {
        let config = configuration.headers {
            DummyHeader(key: "Accept", value: "application/json")
            DummyHeader(key: "Authorization", value: "Bearer token")
        }
        
        let headers = try #require(config.httpAdditionalHeaders as? [String: String])
        
        let expectedHeaders = [
            "Accept": "application/json",
            "Authorization": "Bearer token"
        ]
        #expect(headers == expectedHeaders)
    }
}

extension URLSessionConfigurationExtensionTests {
    struct DummyHeader: RequestHeader {
        let key: String
        let value: String
        var headers: [String: String] {
            return [key: value]
        }
    }
}

extension Tag {
    @Tag internal static var utilities: Self
}
