//
//  DictionaryJSONEncoder.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct DictionaryJSONEncoder {
    private var dictionary: Dictionary<String, any Sendable>
    
    public init(dictionary: Dictionary<String, any Sendable>) {
        self.dictionary = dictionary
    }
}

// MARK: - JSONEncodable
extension DictionaryJSONEncoder: JSONEncodable {
    public func encoded() throws -> Data? {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: dictionary,
                options: .prettyPrinted
            )
            return data
        }catch {
            throw NKError.JSONError.serializationFailed(dictionary: dictionary, error: error)
        }
    }
}
