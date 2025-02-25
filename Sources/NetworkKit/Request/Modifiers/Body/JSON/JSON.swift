//
//  JSON.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public protocol JSONEncodable {
    func encoded() throws -> Data?
}

public struct JSON {
    private var encodable: any JSONEncodable
}

// MARK: - Initializers
extension JSON {
    public init(_ encodable: any JSONEncodable) {
        self.encodable = encodable
    }
    
    @inlinable public init(data: Data?) {
        self.init(JSONData(data: data))
    }
    
    @inlinable public init(_ dictionary: Dictionary<String, any Sendable>) {
        self.init(DictionaryJSONEncoder(dictionary: dictionary))
    }
    
    @inlinable public init(_ object: some Encodable, encoder: JSONEncoder = JSONEncoder()) {
        self.init(CodableJSONEncoder(object, encoder: encoder))
    }
}

// MARK: - RequestBody
extension JSON: RequestBody {
    public var contentType: ContentType? {
        return ContentType(.applicationJson)
    }
    public func body() throws -> Data? {
        return try encodable.encoded()
    }
}
