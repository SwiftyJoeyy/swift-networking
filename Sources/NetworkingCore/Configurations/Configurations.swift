//
//  Configurations.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// A configuration key used to store configurations in ``ConfigurationValues``.
public protocol ConfigurationKey: Sendable {
    /// The type of value associated with this key.
    associatedtype Value: Sendable
    
    /// The default value to use if no value is set in ``ConfigurationValues``.
    static var defaultValue: Self.Value {get}
}

/// Container for storing and accessing type-safe configuration values.
///
/// This type holds a collection of values indexed by their ``ConfigurationKey`` type.
/// Each key has a default value that is used if a custom value is not provided.
public struct ConfigurationValues: Sendable, CustomStringConvertible {
    /// The configuration values storage.
    private var values = [String: any Sendable]()
    
    /// Creates a new ``ConfigurationValues``.
    @inlinable public init() { }
    
    /// Accesses the value associated with the given configuration key type.
    ///
    /// If a value has been previously set for the key, it is returned. Otherwise,
    /// the key's default value is returned.
    ///
    /// - Parameter key: The type of the configuration key.
    public subscript<K: ConfigurationKey>(_ key: K.Type) -> K.Value {
        get {
            guard let value = values[String(describing: key)] else {
                return K.defaultValue
            }
            return unsafeBitCast(value, to: K.Value.self)
        }
        set {
            values[String(describing: key)] = newValue
        }
    }
    
    /// A string that represents the contents of the environment values instance.
    public var description: String {
        guard !values.isEmpty else {
            return "\(String(describing: Self.self)) = []"
        }
        let valuesString = values
            .map({"  \($0): \($1)"})
            .joined(separator: ",\n")
        return """
        \(String(describing: Self.self)) = [
        \(valuesString)
        ]
        """
    }
}

// TODO: - Implement a robust universal Configurations system to apply configurations to Request, Task, Client, RequestModifier.
extension ConfigurationValues {
    /// The decoder used for decoding responses.
    @Config public internal(set) var decoder = JSONDecoder()
    
    /// The encoder used for encoding requests.
    @Config public internal(set) var encoder = JSONEncoder()
    
    /// The base URL used in requests.
    @Config public internal(set) var baseURL: URL? = nil
    
    /// The size of the buffer used for reading files.
    @Config public internal(set) var bufferSize = 1024
}
