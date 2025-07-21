//
//  _ModifiableRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import Foundation

/// A request that can be modified by a ``RequestModifier``.
///
/// Use `_ModifiableRequest` to compose behavior around a base request by attaching
/// one or more modifiers. This enables flexible configuration without altering
/// the original request structure.
///
/// Conforming types define a ``modifier`` using the ``@ModifiersBuilder`` result builder.
///
/// ```swift
/// struct MyRequest: _ModifiableRequest {
///     var path: String { "/v1/user" }
///     var method: HTTPMethod { .get }
///
///     @ModifiersBuilder var modifier: some RequestModifier {
///         AuthorizationToken("abc123")
///         TimeoutInterval(30)
///     }
/// }
/// ```
///
/// In this example, ``MyRequest`` attaches an authorization token and a timeout
/// configuration to the base request.
///
/// Conforming types define a ``modifier`` using the ``@ModifiersBuilder`` result builder,
/// which is applied to the resulting ``URLRequest`` before sending.
///
/// - Note: This protocol is prefixed with `_` to indicate that it is not intended for public use.
public protocol _ModifiableRequest: Request {
    /// The type of modifier applied to the request.
    associatedtype Modifier: RequestModifier
    
    /// A modifier used to transform the final ``URLRequest``.
    ///
    /// Use this property to attach custom behavior or configuration
    /// to a request prior to execution.
    @ModifiersBuilder var modifier: Self.Modifier {get}
}

extension _ModifiableRequest {
    /// Constructs a ``URLRequest`` from this request, using the provided configurations.
    ///
    /// This method is responsible for producing the final ``URLRequest`` that will be
    /// sent over the network. It ensures that all relevant configurations and
    /// modifiers are applied.
    ///
    /// - Parameter configurations: The resolved ``ConfigurationValues`` to use during construction.
    /// - Returns: A fully configured ``URLRequest``.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws(NetworkingError) -> URLRequest {
        _accept(configurations)
        modifier._accept(configurations)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        return try modifier.modifying(consume urlRequest)
    }
}

/// A request paired with a modifier.
///
/// `_ModifiedRequest` composes a base request with a modifier,
/// allowing the modifier to alter the request’s behavior or contents
/// before it's sent.
///
/// For example, suppose you have two endpoints: one to fetch user info and another to update it.
/// If both share the same path and structure, but the update endpoint requires a `POST` method
/// and a request body, you can reuse the original request by applying a modifier.
///
/// ```swift
/// let getInfoRequest = UserInfoRequest()
/// let userInfo = UserInfo(name: "Alice", email: "alice@example.com")
///
/// let updateInfoRequest = _ModifiedRequest(
///     request: getInfoRequest,
///     modifier: PostInfoModifier(userInfo)
/// )
/// ```
///
/// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
@frozen public struct _ModifiedRequest<Contents: Request, Modifier: RequestModifier>: _ModifiableRequest {
    /// The identifier of the underlying request.
    public var id: String {
        return request.id
    }
    
    /// The underlying request to be modified.
    public let request: Contents
    
    /// The modifier applied to the request.
    public let modifier: Modifier
    
    /// Creates a modified request from a base request and a modifier.
    ///
    /// Use this initializer to attach a modifier to an existing request.
    ///
    /// ```swift
    /// let getInfoRequest = UserInfoRequest()
    /// let userInfo = UserInfo(name: "Alice", email: "alice@example.com")
    ///
    /// let updateInfoRequest = _ModifiedRequest(
    ///     request: getInfoRequest,
    ///     modifier: PostInfoModifier(userInfo)
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - request: The base request to modify.
    ///   - modifier: The modifier to apply to the base request.
    @inlinable internal init(request: Contents, modifier: Modifier) {
        self.request = request
        self.modifier = modifier
    }
}
