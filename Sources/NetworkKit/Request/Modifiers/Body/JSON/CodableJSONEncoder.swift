//
//  CodableJSONEncoder.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Encodes an ``Encodable`` object into JSON data.
@frozen public struct CodableJSONEncoder<T: Encodable> {
    /// The encoder to use.
    private var encoder: JSONEncoder?
    
    /// The object to encode.
    private var object: T
    
    /// Creates a new ``CodableJSONEncoder``.
    ///
    /// - Parameters:
    ///  - object: The ``Encodable`` object to encode.
    ///  - encoder: The ``JSONEncoder`` to use.
    public init(_ object: T, encoder: JSONEncoder? = nil) {
        self.object = object
        self.encoder = encoder
    }
}

// MARK: - JSONEncodable
extension CodableJSONEncoder: JSONEncodable {
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
            throw NKError.JSONError.encodingFailed(error)
        }
    }
}
