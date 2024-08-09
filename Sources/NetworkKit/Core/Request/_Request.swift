//
//  _Request.swift
//  
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

public protocol _ModifyableRequest {
    var modifiers: [RequestModifier] {get set}
}

public protocol _Request: _ModifyableRequest {
    func _urlRequest(_ baseURL: URL?) throws -> URLRequest
}
