//
//  FoundationJSONEncodable.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Encodes an ``Encodable`` object into JSON data.
@frozen public struct FoundationJSONEncodable<T: Encodable> {
    /// The encoder to use.
    @usableFromInline internal let encoder: JSONEncoder?
    
    /// The object to encode.
    @usableFromInline internal let object: T
    
    /// Creates a new ``CodableJSONEncoder``.
    ///
    /// - Parameters:
    ///  - object: The ``Encodable`` object to encode.
    ///  - encoder: The ``JSONEncoder`` to use.
    @inlinable public init(_ object: T, encoder: JSONEncoder? = nil) {
        self.object = object
        self.encoder = encoder
    }
}

// MARK: - JSONEncodable
extension FoundationJSONEncodable: JSONEncodable {
    /// Encodes the ``Encodable`` object into JSON data.
    ///
    /// - Returns: The encoded JSON data.
    public func encoded(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        do {
            let baseEncoder = configurations.encoder
            let data = try (encoder ?? baseEncoder).encode(object)
            return data
        }catch {
            throw NetworkingError.JSONError.encodingFailed(error)
        }
    }
}

// MARK: - CustomStringConvertible
extension FoundationJSONEncodable: CustomStringConvertible {
    /// A textual representation of the codable encoder.
    public var description: String {
        "CodableJSONEncoder = \(String(describing: object.self))"
    }
}
