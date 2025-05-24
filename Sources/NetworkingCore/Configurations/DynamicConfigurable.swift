//
//  DynamicConfigurable.swift
//  Networking
//
//  Created by Joe Maghzal on 24/05/2025.
//

import Foundation

/// A type that can accept external configuration values.
///
/// Conforming to `_DynamicConfigurable` allows a type to receive a ``ConfigurationValues``
/// instance from its environment. This is typically used to propagate values down a hierarchy
/// without requiring each type to explicitly manage them.
public protocol _DynamicConfigurable {
    /// Accepts a set of configuration values.
    ///
    /// Use this method to apply externally provided configuration to a conforming type.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    func _accept(_ values: ConfigurationValues)
}

/// A property wrapper that provides access to dynamic configuration values.
///
/// Use ``@Configurations`` in types that support receiving configuration values from
/// the environment. The wrapped value exposes the current ``ConfigurationValues``
/// at the point of access.
///
///
/// ```swift
/// struct MyRequest: Request {
///     @Configurations var configurations
///     ...
/// }
/// ```
///
/// - Warning: Configuration values are only propagated to `@Configurations`
///   properties declared in types that conform to `_DynamicConfigurable`.
///   If a type does not conform, the values will not be updated.
@propertyWrapper public struct Configurations: _DynamicConfigurable {
    /// The type containing the configuration values.
    private let content = Content()
    
    /// Creates a new instance with an empty configuration.
    public init() { }
    
    /// The current configuration values.
    ///
    /// Use this value to access the environment-provided configuration for the
    /// current context.
    public var wrappedValue: ConfigurationValues {
        return content.values
    }
    
    /// Applies new configuration values to the wrapped instance.
    ///
    /// This method is called internally to inject values during evaluation. You typically
    /// do not call this method directly.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        content.values = values
    }
}

extension Configurations {
    /// A type that stores the configuration values.
    ///
    /// This internal type enables reference semantics, allowing configurations to be
    /// efficiently shared and updated across instances.
    internal final class Content {
        /// The current configuration values.
        internal var values: ConfigurationValues
        
        /// Creates a new instance with the specified initial values.
        ///
        /// - Parameter values: The initial configuration values. Defaults to a new instance.
        init(values: ConfigurationValues = ConfigurationValues()) {
            self.values = values
        }
    }
}
