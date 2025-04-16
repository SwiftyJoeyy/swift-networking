//
//  _Request.swift
//  Networking
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

/// Requirements for defining a network request.
///
/// - Warning: This protocol is used internally
/// as a foundation for building request structures.
public protocol _Request {
    /// The request modifiers applied to this request.
    var _modifiers: [any RequestModifier] {get set}
    
    /// Constructs a ``URLRequest`` using the given base url.
    ///
    /// - Parameter baseURL: The base URL to use if the request does not have one.
    /// - Returns: The configured ``URLRequest``.
    func _makeURLRequest(
        _ configurations: borrowing ConfigurationValues
    ) throws -> URLRequest
}
