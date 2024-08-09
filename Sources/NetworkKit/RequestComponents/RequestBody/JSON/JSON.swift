//
//  JSON.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public protocol JSONEncodable {
    func encoded() throws -> Data?
}

public struct JSON {
    private var data: JSONDataType
}

//MARK: - Initializers
extension JSON {
    public init(encodable: JSONEncodable) {
        self.data = .encodable(encodable)
    }
    
    public init(data: Data?) {
        self.data = .data(data)
    }
    
    public init(_ dictionary: Dictionary<String, Any>) {
        self.init(encodable: DictionaryJSONEncoder(dictionary: dictionary))
    }
    
    public init<T: Encodable>(_ object: T, encoder: JSONEncoder = JSONEncoder()) {
        self.init(encodable: CodableJSONEncoder(object, encoder: encoder))
    }
}

//MARK: - RequestBody
extension JSON: RequestBody {
    public var contentType: ContentType {
        return ContentType(.applicationJson)
    }
    public func body() throws -> Data? {
        switch data {
            case .data(let data):
                return data
            case .encodable(let encodable):
                return try encodable.encoded()
        }
    }
}

extension JSON {
    fileprivate enum JSONDataType {
        case data(Data?)
        case encodable(JSONEncodable)
    }
}
