//
//  JSON.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Object that can be encoded into JSON data.
public protocol JSONEncodable {
    /// Encodes the object into JSON data.
    ///
    /// - Returns: The encoded JSON data.
    func encoded(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data?
}

extension Data: JSONEncodable {
    /// Encodes the object into JSON data.
    ///
    /// - Returns: The encoded JSON data.
    public func encoded(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        return self
    }
}

/// A JSON request body.
///
/// The ``JSON`` body can be defined in multiple ways:
/// - Using ``Dicitonary``:
/// ```
/// @Request
/// struct GoogleRequest {
///     var request: some Request {
///         HTTPRequest()
///             .body {
///                 JSON([
///                     "date": "1/16/2025"
///                 ])
///             }
///     }
/// }
/// ```
///
/// - Using ``Encodable``:
/// ```
/// @Request
/// struct GoogleRequest {
///     var request: some Request {
///         HTTPRequest()
///             .body {
///                 JSON(Item())
///             }
///     }
///
///     struct Item: Codable {
///         var date = Date()
///     }
/// }
/// ```
///
/// - Using ``Data``:
/// ```
/// @Request
/// struct GoogleRequest {
///     var request: some Request {
///         HTTPRequest()
///             .body {
///                 let data = try Data(contentsOf: "../file.json")
///                 JSON(data)
///             }
///     }
/// }
/// ```
@frozen public struct JSON {
    /// The JSON encodable object.
    private var encodable: any JSONEncodable

    /// Creates a new ``JSON`` from a ``JSONEncodable``.
    ///
    /// - Parameter encodable: The object to be encoded into JSON.
    public init(_ encodable: any JSONEncodable) {
        self.encodable = encodable
    }
    
    /// Creates a new ``JSON`` from raw JSON data.
    ///
    /// - Parameter data: The raw JSON data.
    @inlinable public init(data: Data) {
        self.init(data)
    }
    
    /// Creates a new ``JSON`` from a dictionary.
    ///
    /// - Parameter dictionary: The dictionary to be encoded.
    @inlinable public init(_ dictionary: Dictionary<String, any Sendable>) {
        self.init(DictionaryJSONEncoder(dictionary: dictionary))
    }
    
    /// Creates a new ``JSON`` instance from an ``Encodable`` object.
    ///
    /// - Parameters:
    ///  - object: The object to be encoded.
    ///  - encoder: The ``JSONEncoder`` to use for encoding.
    @inlinable public init(
        _ object: some Encodable,
        encoder: JSONEncoder? = nil
    ) {
        self.init(CodableJSONEncoder(object, encoder: encoder))
    }
}

// MARK: - RequestBody
extension JSON: RequestBody {
    /// The content type of the request body.
    public var contentType: ContentType? {
        return ContentType(.applicationJson)
    }
    
    /// Encodes the JSON body.
    ///
    /// - Returns: The encoded JSON data.
    public func body(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        return try encodable.encoded(for: configurations)
    }
}
