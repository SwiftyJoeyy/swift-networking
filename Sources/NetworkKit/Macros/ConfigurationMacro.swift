//
//  ConfigurationMacro.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation

/// Macro used to generate a ``ConfigurationKey``.
///
/// This macro creates a ``ConfigurationKey`` from the property it's applied to
/// & generates the corresponding getter & setter for the property defined in
/// the ``ConfigurationValues`` extension:
///
/// ```swift
/// extension ConfigurationValues {
///     @Config var url = URL(string: "example.com")
/// }
///
/// // Expanded
/// extension ConfigurationValues {
///     var navigationTitle = "Title" {
///         get {
///             return self[ConfigurationKey_url.self]
///         }
///         set(newValue) {
///             self[ConfigurationKey_url.self] = newValue
///         }
///     }
///
///     fileprivate struct ConfigurationKey_url: ConfigurationKey {
///         fileprivate static let defaultValue = URL(string: "example.com")
///     }
/// }
/// ```
/// - Warning: The property must be contained in a ``ConfigurationValues`` extension.
@attached(peer, names: prefixed(ConfigurationKey_))
@attached(accessor, names: named(get), named(set))
public macro Config(forceUnwrapped: Bool = false) = #externalMacro(
    module: "NetworkKitMacros",
    type: "ConfigurationKeyMacro"
)
