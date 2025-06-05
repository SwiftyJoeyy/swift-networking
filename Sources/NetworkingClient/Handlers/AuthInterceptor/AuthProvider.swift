//
//  AuthProvider.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

/// A type that manages authentication and provides credentials for requests.
///
/// Use an ``AuthProvider`` to encapsulate how credentials are created, validated,
/// and refreshed. You can inject your provider into a request pipeline or session
/// to automatically apply authentication state.
///
/// The provider supplies a ``RequestModifier`` via ``AuthProvider/credential``,
/// which is attached to requests requiring authentication. When expired,
/// the system can invoke ``AuthProvider/refresh(with:)`` to update it.
///
/// - Important: You are responsible for detecting expiration using ``AuthProvider/requiresRefresh()``
/// and for updating the internal credential inside `refresh(with:)`.
///
/// ```swift
/// struct TokenAuth: AuthProvider {
///     var token: String
///
///     var credential: some RequestModifier {
///         HeaderRequestModifier(name: "Authorization", value: "Bearer \(token)")
///     }
///
///     func requiresRefresh() -> Bool { /* check token expiration */ }
///
///     func refresh(with session: Session) async throws {
///         // request new token
///     }
/// }
/// ```
public protocol AuthProvider: Sendable {
    /// The type of request modifier that carries authentication information.
    associatedtype Credential: RequestModifier
    
    /// The current credential used to modify requests.
    ///
    /// Typically this returns a request modifier that injects a token,
    /// header, or query parameter.
    var credential: Self.Credential {get}
    
    /// Refreshes the credential by interacting with a backend or store.
    ///
    /// This method is called when ``requiresRefresh()`` returns `true`.
    /// Update any internal state so that the next ``credential`` reflects the new data.
    ///
    /// - Parameter session: A `Session` instance for making network requests.
    func refresh(with session: Session) async throws
    
    /// Returns a Boolean value indicating whether the credential needs refreshing.
    ///
    /// Use this method to determine if the current authentication state is valid.
    /// If it returns `true`, ``refresh(with:)`` will be called before sending requests.
    func requiresRefresh() -> Bool
}
