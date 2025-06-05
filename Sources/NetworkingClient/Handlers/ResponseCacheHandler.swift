//
//  ResponseCacheHandler.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

/// A value that defines how a response should be cached.
///
/// Use ``ResponseCacheBehavior`` to control whether a response
/// should be stored in cache, ignored, or conditionally replaced.
///
/// You return this value from a ``ResponseCacheHandler/cache(_:proposedResponse:)``
/// implementation to indicate how the proposed response should be handled.
///
/// - Note: This value does not affect request execution directly.
/// It determines how the response is stored **after** completion.
@frozen public enum ResponseCacheBehavior: Equatable, Hashable, Sendable {
    /// Store the proposed response in the cache.
    case cache
    
    /// Skip caching for this response.
    case ignore
    
    /// Replace or override the cached response manually.
    ///
    /// Use this case to customize how the response is stored.
    /// Pass `nil` to prevent caching, or provide a modified ``CachedURLResponse``.
    case modified(CachedURLResponse?)
}

/// A type that determines whether and how a response should be cached.
///
/// Conform to ``ResponseCacheHandler`` to customize response caching behavior
/// for individual requests. You can:
///
/// - Accept the default cache behavior
/// - Prevent caching
/// - Modify or override the cached response
///
/// Attach a handler to your request configuration using a custom modifier or framework-defined key.
///
/// Use ``DefaultResponseCacheHandler`` to adopt standard behavior,
/// or return ``ResponseCacheBehavior/ignore`` to disable caching.
public protocol ResponseCacheHandler: Sendable {
    /// Evaluates the proposed response and returns a caching policy.
    ///
    /// - Parameters:
    ///   - task: The task associated with the response.
    ///   - proposedResponse: The system-generated response proposed for caching.
    ///
    /// - Returns: A ``ResponseCacheBehavior`` indicating how to handle the response.
    func cache(
        _ task: some NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior
}

extension ResponseCacheHandler where Self == DefaultResponseCacheHandler {
    /// A default cache handler that disables caching.
    ///
    /// Use this value when you want to explicitly prevent any response
    /// from being stored.
    ///
    /// This is equivalent to returning ``ResponseCacheBehavior/ignore``
    /// for every response.
    public static var none: Self {
        return DefaultResponseCacheHandler()
    }
}

/// A basic implementation of ``ResponseCacheHandler`` that accepts all responses.
///
/// This handler always returns ``ResponseCacheBehavior/cache``,
/// instructing the system to store every proposed response as-is.
///
/// Use this type as a baseline if you want to opt into caching by default,
/// or subclass/compose it to implement more advanced behavior.
public struct DefaultResponseCacheHandler: ResponseCacheHandler {
    /// Returns `.cache` for every response.
    public func cache(
        _ task: some NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior {
        return .cache
    }
}

extension Configurable {
    /// Sets the handler used to control how responses are cached.
    ///
    /// Use this method to attach a custom ``ResponseCacheHandler`` that decides
    /// whether a response should be cached, ignored, or modified before storing.
    ///
    /// You can return a predefined handler like ``DefaultResponseCacheHandler`` or
    /// use ``ResponseCacheHandler/none`` to disable caching.
    ///
    /// ```swift
    /// request.cacheHandler(MyCustomCacheHandler())
    /// ```
    ///
    /// - Parameter handler: The handler that manages caching for this request.
    public func cacheHandler(_ handler: some ResponseCacheHandler) -> Self {
        return configuration(\.cacheHandler, handler)
    }
}
