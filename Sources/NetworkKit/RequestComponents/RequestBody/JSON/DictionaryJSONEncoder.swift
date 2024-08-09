//
//  DictionaryJSONEncoder.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public struct DictionaryJSONEncoder {
    private let dictionary: Dictionary<String, Any>
    
    public init(dictionary: Dictionary<String, Any>) {
        self.dictionary = dictionary
    }
}

//MARK: - JSONEncodable
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
