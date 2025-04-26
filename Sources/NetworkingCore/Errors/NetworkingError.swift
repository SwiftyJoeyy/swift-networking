//
//  NetworkingError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public enum NetworkingError: Error, Sendable {
    case invalidRequestURL
    case unexpectedError
}
