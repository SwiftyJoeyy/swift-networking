//
//  URLSessionConfiguration+Extension.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/21/25.
//

import Foundation

extension URLSessionConfiguration {
    public func urlCache(_ cache: URLCache?) -> Self {
        urlCache = cache
        return self
    }
    func requestCachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        requestCachePolicy = policy
        return self
    }
    public func timeoutIntervalForRequest(_ interval: TimeInterval) -> Self {
        timeoutIntervalForRequest = interval
        return self
    }
    public func timeoutIntervalForResource(_ interval: TimeInterval) -> Self {
        timeoutIntervalForResource = interval
        return self
    }
    public func httpMaximumConnectionsPerHost(_ maxConnections: Int) -> Self {
        httpMaximumConnectionsPerHost = maxConnections
        return self
    }
    public func waitForConnectivity(_ waits: Bool) -> Self {
        waitsForConnectivity = waits
        return self
    }
    public func headers(
        @HeadersBuilder headers: @Sendable () -> HeadersGroup
    ) -> Self {
        httpAdditionalHeaders = headers().headers
        return self
    }
}
