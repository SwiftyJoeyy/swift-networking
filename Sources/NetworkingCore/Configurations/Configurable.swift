//
//  Configurable.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// Requirement for types that can be configured using ``ConfigurationValues``.
///
/// Conforming types provide a way to set configuration values using key paths.
public protocol Configurable {
    /// Applies a configuration value to the given key path.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into the ``ConfigurationValues``.
    ///   - value: The value to assign to the given key path.
    func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self
}

extension Configurable {
    /// Sets the base URL for the request.
    public func baseURL(_ url: URL?) -> Self {
        return configuration(\.baseURL, url)
    }
    
    /// Sets the base URL for the request from a string.
    public func baseURL(_ url: String) -> Self {
        return baseURL(URL(string: url))
    }
    
    /// Sets the ``JSONEncoder`` used for encoding requests.
    public func encode(with encoder: JSONEncoder) -> Self {
        return configuration(\.encoder, encoder)
    }
    
    /// Sets the ``JSONDecoder`` used for decoding responses.
    public func decode(with decoder: JSONDecoder) -> Self {
        return configuration(\.decoder, decoder)
    }
    
    /// Sets the buffer size used for reading files.
    public func bufferSize(_ size: Int) -> Self {
        return configuration(\.bufferSize, size)
    }
}
