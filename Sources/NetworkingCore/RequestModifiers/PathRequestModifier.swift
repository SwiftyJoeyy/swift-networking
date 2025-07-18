//
//  PathRequestModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Request modifier that appends paths to a ``URLRequest``'s URL.
///
/// - Note: Use ``Request/appending(paths:)``,
/// or ``Request/appending(path:)``,
/// or ``Request/appending(paths:)``
/// instead of directly using this. 
@RequestModifier @usableFromInline internal struct PathRequestModifier {
    /// The list of paths to append.
    private let paths: [String]
    
    /// Creates a new ``PathRequestModifier`` with the specified paths.
    ///
    /// - Parameter paths: The paths to append to the request URL.
    @usableFromInline internal init(_ paths: [String]) {
        self.paths = paths
    }

    /// Modifies the given ``URLRequest`` by appending paths to its URL.
    ///
    /// - Parameters:
    ///  - request: The original request to modify.
    ///  - configurations: The network configurations.
    ///  
    /// - Returns: The modified ``URLRequest`` with paths appended.
    @usableFromInline internal func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        for path in paths {
            guard !path.isEmpty else {continue}
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *) {
                request.url?.append(path: path)
            }else {
                request.url?.appendPathComponent(path)
            }
        }
        return request
    }
}

// MARK: - CustomStringConvertible
extension PathRequestModifier: CustomStringConvertible {
    @usableFromInline internal var description: String {
        let pathsString = paths.map({"\"\($0)\""}).joined(separator: ", ")
        return """
        PathRequestModifier = {
            paths = [\(pathsString)]
        }
        """
    }
}

// MARK: - Modifier
extension Request {
    
    /// Appends path components to the request URL, skipping any `nil` values.
    ///
    /// Use this method to append one or more optional values to the URL path.
    /// Each non-`nil` value is converted to a string using its `description` property.
    /// `nil` values are ignored.
    ///
    /// ```swift
    /// HTTPRequest()
    ///     .appending("users", userID, nil)
    /// // If userID is 42, results in: /users/42
    /// ```
    ///
    /// - Parameter paths: One or more optional values to append to the URL path.
    /// - Returns: A request with the non-`nil` path components appended.
    @inlinable public func appending(
        _ paths: (any CustomStringConvertible)?...
    ) -> some Request {
        let components = paths.compactMap { path in
            return path.map({String(describing: $0)})
        }
        return modifier(PathRequestModifier(components))
    }
}
