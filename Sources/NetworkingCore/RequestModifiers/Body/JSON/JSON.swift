//
//  JSON.swift
//  Networking
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

extension Data?: JSONEncodable {
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
@frozen public struct JSON<T: JSONEncodable> {
// MARK: - Properties
    /// The configuration values available to this instance.
    @Configurations private var configurations
    
    /// The JSON encodable object.
    @usableFromInline internal let encodable: T

// MARK: - Initializers
    /// Creates a new ``JSON`` from a ``JSONEncodable``.
    ///
    /// - Parameter encodable: The object to be encoded into JSON.
    @inlinable public init(encodable: T) {
        self.encodable = encodable
    }
    
    /// Creates a new ``JSON`` from raw JSON data.
    ///
    /// - Parameter data: The raw JSON data.
    @inlinable public init(data: Data?) where T == Data? {
        self.init(encodable: data)
    }
    
    /// Creates a new ``JSON`` from a dictionary.
    ///
    /// - Parameter dictionary: The dictionary to be encoded.
    @inlinable public init(
        dictionary: [String: any Sendable]?
    ) where T == DictionaryJSONEncodable {
        self.init(encodable: DictionaryJSONEncodable(dictionary: dictionary))
    }
    
    /// Creates a new ``JSON`` from an ``Encodable`` object.
    ///
    /// - Parameters:
    ///  - object: The object to be encoded.
    ///  - encoder: The ``JSONEncoder`` to use for encoding.
    @inlinable public init<Object: Encodable>(
        _ object: Object,
        encoder: JSONEncoder? = nil
    ) where T == FoundationJSONEncodable<Object> {
        self.init(encodable: FoundationJSONEncodable(object, encoder: encoder))
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
    public func body() throws -> Data? {
        return try encodable.encoded(for: configurations)
    }
    
    /// Applies configuration values to the modifier.
    ///
    /// - Parameter values: The configuration values to apply.
    /// - Note: This type is prefixed with `_` to indicate that it is not intended for public use.
    public func _accept(_ values: ConfigurationValues) {
        _configurations._accept(values)
    }
}

// MARK: - CustomStringConvertible
extension JSON: CustomStringConvertible {
    public var description: String {
        precondition(contentType != nil)
        return """
        JSON = {
          contentType = \(contentType!.description),
          body = \(String(describing: encodable))
        }
        """
    }
}

// MARK: - Modifiers
extension Request {
    /// Sets the request body to the JSON-encoded representation of the given value.
    ///
    /// Use this method to serialize a type that conforms to the ``Encodable`` protocol
    /// into a JSON payload for the request body.
    ///
    /// If no encoder is provided, a default ``JSONEncoder`` instance is used.
    ///
    /// ```swift
    /// struct User: Encodable {
    ///     let name: String
    ///     let age: Int
    /// }
    ///
    /// HTTPRequest()
    ///     .method(.post)
    ///     .json(User(name: "Swift", age: 11))
    /// ```
    ///
    /// - Parameters:
    ///   - object: An ``Encodable`` object.
    ///   - encoder: A JSON encoder to use for serialization. If `nil`, a default encoder is used.
    ///
    /// - Returns: A request with the JSON-encoded body set.
    @inlinable public func json<Object: Encodable>(
        _ object: Object,
        encoder: JSONEncoder? = nil
    ) -> some Request {
        modifier(JSON(object, encoder: encoder))
    }
    
    /// Sets the request body to a JSON-encoded dictionary.
    ///
    /// Use this method when you want to encode a lightweight JSON object directly from a dictionary.
    ///
    /// ```swift
    /// HTTPRequest()
    ///     .method(.post)
    ///     .json(["username": "swift", "active": true])
    /// ```
    ///
    /// - Parameter dictionary: A dictionary to encode as a JSON object.
    /// - Returns: A request with the JSON-encoded body set.
    @inlinable public func json(
        dictionary: [String: any Sendable]?
    ) -> some Request {
        modifier(JSON(dictionary: dictionary))
    }
    
    /// Sets the request body to raw JSON data.
    ///
    /// Use this method when you already have a ``Data`` instance
    /// containing a valid JSON payload.
    ///
    /// This bypasses encoding and inserts the data as-is into the request body.
    ///
    /// ```swift
    /// let data = ...
    ///
    /// HTTPRequest()
    ///     .method(.post)
    ///     .json(data)
    /// ```
    ///
    /// - Parameter data: A ``Data`` instance containing a JSON payload.
    /// - Returns: A request with the specified data set as the body.
    @inlinable public func json(
        data: Data?
    ) -> some Request {
        modifier(JSON(data: data))
    }
}
