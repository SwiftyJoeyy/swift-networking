//
//  Parameter.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public typealias ParametersGroup = Parameter.Group

public struct Parameter: RequestParameter {
    public var key: String
    public var value: [String?]
    
    public var parameters: [URLQueryItem] {
        return value.map({URLQueryItem(name: key, value: $0)})
    }
    
    public init(_ key: String, value: [String?]) {
        self.key = key
        self.value = value
    }
    
    public init(_ key: String, value: String?) {
        self.init(key, value: [value])
    }
}

extension Parameter {
    public struct Group: RequestParameter {
        public var parameters: [URLQueryItem]
        
        public init(_ parameters: [URLQueryItem]) {
            self.parameters = parameters
        }
        public init(_ parameters: [URLQueryItem?]) {
            self.init(parameters.compactMap(\.self))
        }
        public init(_ parameters: [any RequestParameter]) {
            self.init(parameters.flatMap(\.parameters))
        }
        public init(@ParametersBuilder _ parameters: () -> ParametersGroup) {
            self = parameters()
        }
    }
}
