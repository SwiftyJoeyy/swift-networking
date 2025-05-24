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
public protocol RequestModifier: _DynamicConfigurable {
    /// Modifies the given ``URLRequest`` and returns the updated version.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///
    /// - Returns: The ``URLRequest`` with the modifier applied to it.
    func modifying(_ request: consuming URLRequest) throws -> URLRequest
}

extension RequestModifier {
    /// Applies configuration values to the modifier.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) { }
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
