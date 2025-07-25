//
//  URLSessionConfiguration+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 2/21/25.
//

import Foundation
import NetworkingCore

extension URLSessionConfiguration {
    /// Sets the ``URLCache`` for the session configuration.
    ///
    /// - Parameter cache: The cache to be used.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func urlCache(_ cache: URLCache?) -> Self {
        urlCache = cache
        return self
    }
    
    /// Sets the request cache policy for the session configuration.
    ///
    /// - Parameter policy: The cache policy to use for requests.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func requestCachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        requestCachePolicy = policy
        return self
    }
    
    /// Sets the timeout interval for individual requests.
    ///
    /// - Parameter interval: The timeout interval in seconds.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func timeoutIntervalForRequest(_ interval: TimeInterval) -> Self {
        timeoutIntervalForRequest = interval
        return self
    }
    
    /// Sets the timeout interval for the entire resource load.
    ///
    /// - Parameter interval: The timeout interval in seconds.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func timeoutIntervalForResource(_ interval: TimeInterval) -> Self {
        timeoutIntervalForResource = interval
        return self
    }
    
    /// Sets the maximum number of simultaneous connections per host.
    ///
    /// - Parameter maxConnections: The maximum number of connections.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func httpMaximumConnectionsPerHost(_ maxConnections: Int) -> Self {
        httpMaximumConnectionsPerHost = maxConnections
        return self
    }
    
    /// Configures whether the session should wait for network connectivity.
    ///
    /// - Parameter waits: Whether the session should
    ///   wait for connectivity before making a request.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func waitForConnectivity(_ waits: Bool) -> Self {
        waitsForConnectivity = waits
        return self
    }
    
    /// Sets additional HTTP headers for the session configuration.
    ///
    /// - Parameter header: The headers to be added.
    /// - Returns: The modified ``URLSessionConfiguration``.
    public func headers(
        @HeadersBuilder header: () -> some RequestHeader
    ) -> Self {
        httpAdditionalHeaders = header().headers
        return self
    }
}
