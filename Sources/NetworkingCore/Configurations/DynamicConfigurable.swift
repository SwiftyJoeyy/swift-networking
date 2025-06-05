//
//  DynamicConfigurable.swift
//  Networking
//
//  Created by Joe Maghzal on 24/05/2025.
//

import Foundation

/// A type that receives configuration values from the surrounding context.
///
/// Conforming to `_DynamicConfigurable` allows a type to accept
/// externally provided ``ConfigurationValues``. This is typically used
/// for automatic propagation of values through a request or modifier tree.
///
/// Types conforming to this protocol participate in implicit configuration
/// injection.
///
/// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
public protocol _DynamicConfigurable {
    /// Applies configuration values to the conforming instance.
    ///
    /// You don't call this method directly. The system invokes it to
    /// inject configuration into dynamically configurable types.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    func _accept(_ values: ConfigurationValues)
}

/// A property wrapper that provides access to dynamic configuration values.
///
/// Use `@Configurations` to access the current ``ConfigurationValues``
/// from the environment. The wrapper exposes the configuration available
/// at the point where it's evaluated.
///
/// The wrapped value reflects any values passed through a parent
/// type that conforms to `_DynamicConfigurable`.
///
/// ```swift
/// struct MyRequest: Request {
///     @Configurations var configurations
///     ...
/// }
/// ```
///
/// - Warning: Configuration values are only injected into types that conform to
/// `_DynamicConfigurable`. If your type doesn't conform, the configuration will
///  remain empty.
///
/// You typically don’t interact with this type directly—it's injected automatically
/// in frameworks that support composable configuration.
@propertyWrapper public struct Configurations: _DynamicConfigurable {
    /// The box containing the configuration values.
    private let content = Content()
    
    /// Creates a new instance with an empty configuration.
    public init() { }
    
    /// The current configuration values.
    ///
    /// Use this value to read from the environment-provided configuration
    /// for the current request or operation.
    public var wrappedValue: ConfigurationValues {
        return content.values
    }
    
    /// Applies new configuration values to the wrapped instance.
    ///
    /// This method is called automatically by systems that support
    /// dynamic configuration. You don’t typically call it yourself.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        content.values = values
    }
    
    /// Sets a configuration value dynamically using a key path.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - keyPath: The key path of the configuration value to update.
    package func setValue<V>(
        _ value: V,
        for keyPath: WritableKeyPath<ConfigurationValues, V>
    ) {
        content.values[keyPath: keyPath] = value
    }
}

extension Configurations {
    /// A container that holds configuration values.
    ///
    /// This type provides reference semantics to allow
    /// shared mutable state between multiple wrapper instances.
    fileprivate final class Content {
        /// The current configuration values.
        fileprivate var values: ConfigurationValues
        
        /// Creates a new container with the specified values.
        fileprivate init(values: ConfigurationValues = ConfigurationValues()) {
            self.values = values
        }
    }
}
