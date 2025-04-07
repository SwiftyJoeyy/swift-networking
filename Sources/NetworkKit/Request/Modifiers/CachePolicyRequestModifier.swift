//
//  CachePolicyRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation

/// Request modifier for setting the cache policy for a ``URLRequest``.
///
/// - Note: Use ``Request/cachePolicy(_:)`` instead of directly using this.
@usableFromInline internal struct CachePolicyRequestModifier {
    /// The cache policy to apply to the request.
    private let cachePolicy: URLRequest.CachePolicy
    
    /// Creates a new ``CachePolicyRequestModifier`` with the specified cache policy.
    ///
    /// - Parameter cachePolicy: The cache policy to apply.
    @usableFromInline internal init(_ cachePolicy: URLRequest.CachePolicy) {
        self.cachePolicy = cachePolicy
    }
}

// MARK: - RequestModifier
extension CachePolicyRequestModifier: RequestModifier {
    /// Modifies the given ``URLRequest`` by setting its cache policy.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest`` with the cache policy set.
    @usableFromInline internal func modifying(
        _ request: consuming URLRequest,
        with configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        request.cachePolicy = cachePolicy
        return request
    }
}

// MARK: - Modifier
extension Request {
    /// Applies a cache policy modifier to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .cachePolicy(.reloadIgnoringCacheData)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter cachePolicy: The cache policy to set.
    /// - Returns: A request with the specified cache policy applied.
    @inlinable public consuming func cachePolicy(
        _ cachePolicy: URLRequest.CachePolicy
    ) -> some Request {
        modifier(CachePolicyRequestModifier(cachePolicy))
    }
}
