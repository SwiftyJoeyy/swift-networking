//
//  Configurable.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// A type that supports applying configuration values..
///
/// Use the ``configuration(_:_:)-63ee0`` method to set configuration values dynamically,
/// or use one of the convenience methods provided in the protocol extension.
public protocol Configurable {
    /// Sets a configuration value using a key path.
    ///
    /// Use this method to modify the configuration associated with key.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into ``ConfigurationValues``.
    ///   - value: The value to set for the given key path.
    @discardableResult func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self
}

extension Configurable {
    /// Sets the base URL used for building a request.
    @discardableResult public func baseURL(_ url: URL?) -> Self {
        return configuration(\.baseURL, url)
    }
    
    /// Sets the base URL using a string.
    ///
    /// - Note: If the string is invalid, the base URL becomes `nil`.
    @discardableResult public func baseURL(_ url: String) -> Self {
        return baseURL(URL(string: url))
    }
    
    /// Sets the encoder used for encoding request bodies.
    @discardableResult public func encode(with encoder: JSONEncoder) -> Self {
        return configuration(\.encoder, encoder)
    }
    
    /// Sets the decoder used for decoding responses.
    @discardableResult public func decode(with decoder: JSONDecoder) -> Self {
        return configuration(\.decoder, decoder)
    }
    
    /// Sets the buffer size for reading files.
    @discardableResult public func bufferSize(_ size: Int) -> Self {
        return configuration(\.bufferSize, size)
    }
}
