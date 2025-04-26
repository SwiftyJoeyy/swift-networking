//
//  DictionaryJSONEncoder.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Encodes a dictionary into JSON data.
@frozen public struct DictionaryJSONEncoder {
    /// The dictionary to encode.
    @usableFromInline internal let dictionary: Dictionary<String, any Sendable>
    
    /// Creates a new ``DictionaryJSONEncoder``.
    ///
    /// - Parameter dictionary: The dictionary to encode.
    @inlinable public init(dictionary: Dictionary<String, any Sendable>) {
        self.dictionary = dictionary
    }
}

// MARK: - JSONEncodable
extension DictionaryJSONEncoder: JSONEncodable {
    /// Encodes the dictionary into JSON data.
    ///
    /// - Returns: The encoded JSON data.
    public func encoded(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: dictionary,
                options: [.prettyPrinted, .fragmentsAllowed]
            )
            return data
        }catch {
            throw NetworkingError.JSONError.serializationFailed(dictionary: dictionary, error: error)
        }
    }
}

// MARK: - CustomStringConvertible
extension DictionaryJSONEncoder: CustomStringConvertible {
    public var description: String {
        guard !dictionary.isEmpty else {
            return "DictionaryJSONEncoder = []"
        }
        let dictString = dictionary.map(\.key).joined(separator: ",\n")
        return """
        DictionaryJSONEncoder (\(dictionary.count)) = [
        \(dictString)
        ]
        """
    }
}
