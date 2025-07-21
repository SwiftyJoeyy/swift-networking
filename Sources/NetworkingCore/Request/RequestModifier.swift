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
///     ) throws(NetworkingError) -> URLRequest {
///         request.timeoutInterval = timeoutInterval
///         return request
///     }
/// }
/// ```

/// Type that modifies a ``URLRequest`` before it is sent.
///
/// Conforming to ``RequestModifier`` allows you to apply transformations to a request
/// at runtime. This is useful for injecting headers, changing timeouts, or applying
/// other custom logic before the request is executed.
///
/// Types that conform to this protocol are typically used within a networking pipeline,
/// and are expected to implement the ``modifying(_:)`` method to alter the request.
///
///
/// ```swift
/// @RequestModifier struct TimeoutRequestModifier {
///     @Configurations var config
///
///     func modifying(
///         _ request: consuming URLRequest
///     ) throws(NetworkingError) -> URLRequest {
///         request.timeoutInterval = config.timeoutInterval
///         return request
///     }
/// }
/// ```
///
/// - Warning: You should **not** conform to this protocol manually.
/// Instead, use the ``@RequestModifier`` macro, which handles required wiring
/// and ensures the modifier integrates correctly with the configuration system.
public protocol RequestModifier: _DynamicConfigurable {
    /// Modifies the given ``URLRequest`` and returns the updated version.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///
    /// - Returns: The ``URLRequest`` with the modifier applied to it.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest
}

extension RequestModifier {
    /// Applies configuration values to the modifier.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) { }
}

extension Request {
    /// Use this method to apply a ``RequestModifier`` to a ``Request`` type, enabling
    /// dynamic customization of the underlying ``URLRequest`` before it is sent.
    /// This is typically used to inject headers, authentication tokens, timeouts,
    /// or any other request-level adjustments.
    ///
    /// The modifier will be invoked during request resolution, allowing it to
    /// operate with full access to configurations and runtime context.
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
        return _ModifiedRequest(request: self, modifier: modifier)
    }
}
