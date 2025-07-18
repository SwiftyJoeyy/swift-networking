//
//  ModifiableRequest.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import Foundation

/// A request that can be modified by a ``RequestModifier``.
///
/// Use ``ModifiableRequest`` to compose behavior around a base request by attaching
/// one or more modifiers. This enables flexible configuration without altering
/// the original request structure.
///
/// Conforming types define a ``modifier`` using the ``@ModifiersBuilder`` result builder.
///
/// ```swift
/// struct MyRequest: ModifiableRequest {
///     var path: String { "/v1/user" }
///     var method: HTTPMethod { .get }
///
///     @ModifiersBuilder
///     var modifier: some RequestModifier {
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
/// - Note: Prefer using ``ModifiedRequest`` over creating custom ``ModifiableRequest``s.
public protocol ModifiableRequest: Request {
    /// The type of modifier applied to the request.
    associatedtype Modifier: RequestModifier
    
    /// A modifier used to transform the final ``URLRequest``.
    ///
    /// Use this property to attach custom behavior or configuration
    /// to a request prior to execution.
    @ModifiersBuilder var modifier: Self.Modifier {get}
}

extension ModifiableRequest {
    /// Creates a ``URLRequest`` by applying the modifier to the base request.
    ///
    /// This method first calls `_makeURLRequest(with:)` on the underlying request,
    /// then passes the result to the ``modifier`` for further transformation.
    ///
    /// - Returns: A modified ``URLRequest`` ready to be sent.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _makeURLRequest(
        with configurations: ConfigurationValues
    ) throws(NetworkingError) -> URLRequest {
        _accept(configurations)
        
        let urlRequest = try request._makeURLRequest(with: configurations)
        return try modifier.modifying(consume urlRequest)
    }
    
    /// Applies the given configuration values to the request and its modifier.
    ///
    /// This method forwards the provided `ConfigurationValues` to both the
    /// underlying `request` and its associated `modifier`. It is used to
    /// propagate configuration context through compositional request layers.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        modifier._accept(values)
    }
}

/// A request paired with a modifier.
///
/// ``ModifiedRequest`` composes a base request with a modifier,
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
/// let updateInfoRequest = ModifiedRequest(
///     request: getInfoRequest,
///     modifier: PostInfoModifier(userInfo)
/// )
/// ```
///
/// Alternatively, you can modify the request inline using built-in modifiers:
///
/// ```swift
/// let getInfoRequest = UserInfoRequest()
/// let userInfo = UserInfo(name: "Alice", email: "alice@example.com")
///
/// let updateInfoRequest = ModifiedRequest(request: getInfoRequest) {
///     JSON(userInfo)
///     HTTPMethodRequestModifier(.post)
/// }
/// ```
///
/// Prefer using the built-in modifier APIs for a more expressive and concise syntax,
/// rather than constructing ``ModifiedRequest`` directly.
///
/// ```swift
/// let updateInfoRequest = UserInfoRequest()
///     .method(.post)
///     .body {
///         JSON(UserInfo(name: "Alice", email: "alice@example.com"))
///     }
/// ```
@frozen public struct ModifiedRequest<Content: Request, Modifier: RequestModifier>: ModifiableRequest {
    /// The identifier of the underlying request.
    public var id: String {
        return request.id
    }
    
    /// The underlying request to be modified.
    public let request: Content
    
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
    /// let updateInfoRequest = ModifiedRequest(
    ///     request: getInfoRequest,
    ///     modifier: PostInfoModifier(userInfo)
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - request: The base request to modify.
    ///   - modifier: The modifier to apply to the base request.
    @inlinable public init(request: Content, modifier: Modifier) {
        self.request = request
        self.modifier = modifier
    }
    
    /// Creates a modified request using a base request and a modifier builder.
    ///
    /// Use this initializer to attach one or more modifiers to an existing request
    /// using a ``@ModifiersBuilder`` block. This approach enables a fluent and
    /// expressive way to compose request behavior.
    ///
    /// ```swift
    /// let getInfoRequest = UserInfoRequest()
    /// let userInfo = UserInfo(name: "Alice", email: "alice@example.com")
    ///
    /// let updateInfoRequest = ModifiedRequest(request: getInfoRequest) {
    ///     JSON(userInfo)
    ///     HTTPMethodRequestModifier(.post)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - request: The base request to modify.
    ///   - modifier: The modifier to apply to the base request.
    @inlinable public init(
        request: Content,
        @ModifiersBuilder modifier: () -> Modifier
    ) {
        self.init(request: request, modifier: modifier())
    }
}
