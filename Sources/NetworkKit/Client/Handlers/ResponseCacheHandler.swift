//
//  ResponseCacheHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

public protocol ResponseCacheHandler: Sendable {
    func cache(
        _ task: any NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior
}

public enum ResponseCacheBehavior: Sendable {
    case cache
    case ignore
    case modified(CachedURLResponse?)
}

extension ResponseCacheHandler where Self == DefaultResponseCacheHandler {
    public static var none: Self {
        return DefaultResponseCacheHandler()
    }
}

public struct DefaultResponseCacheHandler: ResponseCacheHandler {
    public func cache(
        _ task: any NetworkingTask,
        proposedResponse: CachedURLResponse
    ) async -> ResponseCacheBehavior {
        return .cache
    }
}
