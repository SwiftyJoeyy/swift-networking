//
//  DictionaryJSONEncodable.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Encodes a dictionary into JSON data.
@frozen public struct DictionaryJSONEncodable {
    /// The dictionary to encode.
    @usableFromInline internal let dictionary: [String: any Sendable]?
    
    /// Creates a new ``DictionaryJSONEncoder``.
    ///
    /// - Parameter dictionary: The dictionary to encode.
    @inlinable public init(dictionary: [String: any Sendable]?) {
        self.dictionary = dictionary
    }
}

// MARK: - JSONEncodable
extension DictionaryJSONEncodable: JSONEncodable {
    /// Encodes the dictionary into JSON data.
    ///
    /// - Returns: The encoded JSON data.
    public func encoded(
        for configurations: borrowing ConfigurationValues
    ) throws(NetworkingError) -> Data? {
        guard let dictionary, !dictionary.isEmpty else {
            return nil
        }
        
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            throw .serialization(
                .invalidObject(dictionary: dictionary)
            )
        }
        do {
            let data = try JSONSerialization.data(
                withJSONObject: dictionary,
                options: [.prettyPrinted, .fragmentsAllowed]
            )
            return data
        }catch {
            throw .serialization(
                .serializationFailed(
                    dictionary: dictionary,
                    error: error
                )
            )
        }
    }
}

// MARK: - CustomStringConvertible
extension DictionaryJSONEncodable: CustomStringConvertible {
    public var description: String {
        guard let dictionary, !dictionary.isEmpty else {
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
