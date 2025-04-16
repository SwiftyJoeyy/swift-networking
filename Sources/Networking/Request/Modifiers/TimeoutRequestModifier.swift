//
//  TimeoutRequestModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Request modifier for setting the timeout interval for a ``URLRequest``
///
/// - Note: Use ``Request/timeout(_:)`` instead of directly using this.
@usableFromInline internal struct TimeoutRequestModifier {
    /// The timeout interval in seconds.
    private let timeoutInterval: TimeInterval
    
    /// Creates a new ``TimeoutRequestModifier`` with the specified timeout interval.
    ///
    /// - Parameter timeoutInterval: The timeout duration in seconds.
    @usableFromInline internal init(_ timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
}

// MARK: - RequestModifier
extension TimeoutRequestModifier: RequestModifier {
    /// Modifies the given ``URLRequest`` by setting its timeout interval.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified `URLRequest` with the timeout set.
    @usableFromInline internal func modifying(
        _ request: consuming URLRequest,
        with configurations: borrowing ConfigurationValues
    ) throws -> URLRequest {
        request.timeoutInterval = timeoutInterval
        return request
    }
}

// MARK: - Modifier
extension Request {
    /// Applies a timeout modifier to the request.
    ///
    /// ```
    /// @Request
    /// struct GoogleRequest {
    ///     var request: some Request {
    ///         HTTPRequest()
    ///             .timeoutInterval(90)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter timeoutInterval: The timeout duration in seconds.
    /// - Returns: A request with the specified timeout applied.
    @inlinable public consuming func timeout(
        _ timeoutInterval: TimeInterval
    ) -> some Request {
        modifier(TimeoutRequestModifier(timeoutInterval))
    }
}
