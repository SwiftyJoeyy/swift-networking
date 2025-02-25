//
//  _Request.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

public protocol _Request {
    var _modifiers: [any RequestModifier] {get set}
    func _urlRequest(_ baseURL: URL?) throws -> URLRequest
}
