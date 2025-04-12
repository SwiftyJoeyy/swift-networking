//
//  RedirectionHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

@frozen public enum RedirectionBehavior: Equatable, Hashable, Sendable {
    case redirect
    case ignore
    case modified(URLRequest?)
}

public protocol RedirectionHandler: Sendable {
    func redirect(
        _ task: some NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior
}

extension RedirectionHandler where Self == DefaultRedirectionHandler {
    public static var none: Self {
        return DefaultRedirectionHandler()
    }
}

public struct DefaultRedirectionHandler: RedirectionHandler {
    public func redirect(
        _ task: some NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior {
        return .redirect
    }
}
