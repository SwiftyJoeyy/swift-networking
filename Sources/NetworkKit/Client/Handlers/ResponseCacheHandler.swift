//
//  ResponseCacheHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

@frozen public enum ResponseCacheBehavior: Equatable, Hashable, Sendable {
    case cache
    case ignore
    case modified(CachedURLResponse?)
}

public protocol ResponseCacheHandler: Sendable {
    func cache(
        _ task: some NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior
}

extension ResponseCacheHandler where Self == DefaultResponseCacheHandler {
    public static var none: Self {
        return DefaultResponseCacheHandler()
    }
}

public struct DefaultResponseCacheHandler: ResponseCacheHandler {
    public func cache(
        _ task: some NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior {
        return .cache
    }
}
