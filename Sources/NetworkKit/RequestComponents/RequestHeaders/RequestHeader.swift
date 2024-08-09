//
//  RequestHeader.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public protocol RequestHeader: RequestHeadersCollection {
    var key: String {get}
    var value: String {get}
}

//MARK: - RequestHeadersCollection
extension RequestHeader {
    public var headers: [String: String] {
        return [key: value]
    }
}
