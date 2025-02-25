//
//  CodableJSONEncoder.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct CodableJSONEncoder<T: Encodable> {
    private var encoder: JSONEncoder
    private var object: T
    
    public init(_ object: T, encoder: JSONEncoder = JSONEncoder()) {
        self.object = object
        self.encoder = encoder
    }
}

// MARK: - JSONEncodable
extension CodableJSONEncoder: JSONEncodable {
    public func encoded() throws -> Data? {
        do {
            let data = try encoder.encode(object)
            return data
        }catch {
            throw NKError.JSONError.encodingFailed(error)
        }
    }
}
