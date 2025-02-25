//
//  RedirectionHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

public protocol RedirectionHandler: Sendable {
    func redirect(
        _ task: any NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior
}

public enum RedirectionBehavior: Sendable {
    case redirect
    case ignore
    case modified(URLRequest?)
}

extension RedirectionHandler where Self == DefaultRedirectionHandler {
    public static var none: Self {
        return DefaultRedirectionHandler()
    }
}

public struct DefaultRedirectionHandler: RedirectionHandler {
    public func redirect(
        _ task: any NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior {
        return .redirect
    }
}
