//
//  RedirectionHandler.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

/// A value that defines how an HTTP redirection should be handled.
///
/// Use ``RedirectionBehavior`` to decide whether to follow, ignore,
/// or modify an HTTP redirect during request execution.
///
/// You return one of these cases from a
/// ``RedirectionHandler/redirect(_:redirectResponse:newRequest:)``
/// implementation to control how the redirection is processed.
@frozen public enum RedirectionBehavior: Equatable, Hashable, Sendable {
    /// Follow the redirection as proposed.
    case redirect
    
    /// Ignore the redirection and return the original response.
    case ignore
    
    /// Provide a custom request to use instead of the proposed redirect.
    ///
    /// Pass `nil` to explicitly cancel the redirect.
    case modified(URLRequest?)
}

/// A type that handles HTTP redirection behavior.
///
/// Conform to ``RedirectionHandler`` to inspect or modify redirect responses
/// during request execution. You can choose to follow the redirect,
/// ignore it, or override the new request.
///
/// Attach a handler using ``Configurable/redirectionHandler(_:)``.
public protocol RedirectionHandler: Sendable {
    /// Evaluates the redirect response and determines the next step.
    ///
    /// - Parameters:
    ///   - task: The networking task in progress.
    ///   - redirectResponse: The response that triggered the redirect.
    ///   - newRequest: The new request proposed by the system.
    ///
    /// - Returns: A ``RedirectionBehavior`` that indicates how to proceed.
    func redirect(
        _ task: some NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior
}

extension RedirectionHandler where Self == DefaultRedirectionHandler {
    /// A redirection handler that disables all redirections.
    ///
    /// This value causes the request to continue without following any redirects.
    public static var none: Self {
        return DefaultRedirectionHandler()
    }
}

/// A redirection handler that accepts all redirects.
///
/// This type always returns ``RedirectionBehavior/redirect``, allowing
/// the request to follow any proposed redirection without modification.
///
/// Use this as a default or baseline implementation.
public struct DefaultRedirectionHandler: RedirectionHandler {
    /// Always follows the proposed redirection.
    public func redirect(
        _ task: some NetworkingTask,
        redirectResponse: URLResponse,
        newRequest: URLRequest
    ) async -> RedirectionBehavior {
        return .redirect
    }
}

extension Configurable {
    /// Sets the handler used to manage HTTP redirections.
    ///
    /// Use this method to override the default redirection behavior for a request.
    /// You can ignore, modify, or explicitly cancel redirects based on response metadata.
    ///
    /// - Parameter handler: A type conforming to ``RedirectionHandler``.
    ///
    /// - Note: Use ``RedirectionHandler/none`` to disable redirects.
    public func redirectionHandler(_ handler: some RedirectionHandler) -> Self {
        return configuration(\.redirectionHandler, handler)
    }
}
