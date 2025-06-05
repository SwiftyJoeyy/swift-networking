//
//  Configurations.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// A key for reading and writing values in a ``ConfigurationValues`` instance.
///
/// You use this protocol to define keys that store type-safe configuration values.
/// Values are retrieved through the key type, and if no value is set, the key’s
/// ``ConfigurationKey/defaultValue`` is used.
///
/// You typically don’t conform to this protocol directly. Instead, declare new
/// keys using the ``@Config`` macro:
///
/// ```swift
/// extension ConfigurationValues {
///     @Config public var timeout: Int = 30
/// }
/// ```
///
/// If you prefer to define a key manually:
///
/// ```swift
/// struct TimeoutKey: ConfigurationKey {
///     static let defaultValue = 60
/// }
///
/// extension ConfigurationValues {
///     var timeout: Int {
///         get { self[TimeoutKey.self] }
///         set { self[TimeoutKey.self] = newValue }
///     }
/// }
/// ```
public protocol ConfigurationKey: Sendable {
    /// The type of value associated with the key.
    associatedtype Value: Sendable
    
    /// The default value used when no explicit value is set.
    static var defaultValue: Self.Value {get}
}

/// A collection of type-safe configuration values.
///
/// You use `ConfigurationValues` to read and write custom configuration values
/// that affect how a request or process behaves.
///
/// Each value is identified by a key type that conforms to ``ConfigurationKey``.
/// If no custom value is set for a key, the default value is used.
public struct ConfigurationValues: Sendable, CustomStringConvertible {
    /// The configuration values storage.
    private var box = ProperiesBox()
    
    /// Creates a new configuration container.
    @inlinable public init() { }
    
    /// Accesses the value associated with the given key type.
    ///
    /// If no value is set, the key’s default value is returned.
    ///
    /// - Parameter key: A key type that conforms to ``ConfigurationKey``.
    public subscript<K: ConfigurationKey>(_ key: K.Type) -> K.Value {
        _read {
            guard let value = box.value(for: ObjectIdentifier(key)) as? K.Value else {
                yield K.defaultValue
                return
            }
            yield value
        }
        set {
            ensureUniqueBox()
            box.setValue(newValue, for: ObjectIdentifier(key))
        }
    }
    
    /// Ensures that the storage reference is uniquely owned before mutation.
    @inline(__always) private mutating func ensureUniqueBox() {
        guard !isKnownUniquelyReferenced(&box) else {return}
        box = ProperiesBox(values: box.allValues())
    }
    
    /// A textual representation of all active configuration values.
    ///
    /// This string lists all explicitly set values. Keys with only default values are not included.
    public var description: String {
        let values = box.allValues()
        guard !values.isEmpty else {
            return "\(String(describing: Self.self)) = []"
        }
        let valuesString = values
            .map({"  \($0) : \($1)"})
            .joined(separator: ",\n")
        return """
        \(String(describing: Self.self)) = [
        \(valuesString)
        ]
        """
    }
}

extension ConfigurationValues {
    /// A type that stores configuration values with thread-safe access.
    ///
    /// This type is used internally to avoid value-type copying during mutation.
    fileprivate final class ProperiesBox: @unchecked Sendable {
// MARK: - Properties
        /// A lock to ensure thread safety when reading or writing values.
        private var lock = os_unfair_lock_s()
        
        /// The stored configuration values, keyed by object identifier.
        private var values: [ObjectIdentifier: any Sendable]
        
// MARK: - Initializer
        /// Creates a new storage box.
        fileprivate init(values: [ObjectIdentifier: any Sendable] = [:]) {
            self.values = values
        }
       
// MARK: - Functions
        /// Stores a value for the given key.
        fileprivate func setValue(
            _ value: any Sendable,
            for key: ObjectIdentifier
        ) {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            values[key] = value
        }
        
        /// Returns the stored value for the given key, if it exists.
        fileprivate func value(for key: ObjectIdentifier) -> (any Sendable)? {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return values[key]
        }
        
        /// Returns all stored values.
        fileprivate func allValues() -> [ObjectIdentifier: any Sendable] {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return values
        }
    }
}

extension ConfigurationValues {
    /// The decoder used to decode response bodies.
    ///
    /// This value is used by any request that expects to parse a response into a decodable type.
    @Config public internal(set) var decoder = JSONDecoder()
    
    /// The encoder used to encode request bodies.
    ///
    /// This value is used when serializing a request's body from an encodable value.
    @Config public internal(set) var encoder = JSONEncoder()
    
    /// The base URL used to resolve relative paths.
    ///
    /// If this value is set, any request with a relative path will resolve it against this base.
    @Config public internal(set) var baseURL: URL? = nil
    
    /// The size of the buffer used for file reads.
    ///
    /// This value controls the number of bytes read at a time when streaming files from disk.
    @Config public internal(set) var bufferSize = 1024
}
