//
//  RequestParameter.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public protocol RequestParameter: RequestParametersCollection {
    var key: String {get set}
    var value: [String?] {get set}
}

//MARK: - RequestParametersCollection
extension RequestParameter {
    public var parameters: [URLQueryItem] {
        return value.map({URLQueryItem(name: key, value: $0)})
    }
}
