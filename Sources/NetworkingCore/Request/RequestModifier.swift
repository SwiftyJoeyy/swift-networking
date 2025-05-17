//
//  RequestModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

/// Requirements for defining a request modifier. ``RequestModifier``
/// are used to modify ``URLRequest`` objects before they are sent.
///
/// ```
/// struct TimeoutRequestModifier: RequestModifier {
///     let timeoutInterval: TimeInterval
///
///     func modifying(
///         _ request: consuming URLRequest,
///         with configurations: borrowing NetworkConfigurations
///     ) throws -> URLRequest {
///         request.timeoutInterval = timeoutInterval
///         return request
///     }
/// }
/// ```
public protocol RequestModifier {
    /// Modifies the given ``URLRequest`` and returns the updated version.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///
    /// - Returns: The ``URLRequest`` with the modifier applied to it.
    func modifying(
        _ request: consuming URLRequest,
        with configurations: borrowing ConfigurationValues
    ) throws -> URLRequest
}

extension Request {
    /// Applies a request modifier to the request.
    ///
    /// Use this to modify a ``Request``:
    ///
    /// ```swift
    /// let signedRequest = UserInfoRequest()
    ///     .modifier(AuthorizationToken("abc123"))
    /// ```
    ///
    /// - Parameter modifier: The modifier to apply.
    /// - Returns: The modified request.
    @inlinable public func modifier<Modifier: RequestModifier>(
        _ modifier: Modifier
    ) -> some Request {
        ModifiedRequest(request: self, modifier: modifier)
    }
}
