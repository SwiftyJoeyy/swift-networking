//
//  NetworkingError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

// TODO: - enhance NetworkingError to specify the type of each error
// TODO: - Make all throwing functions type throws
public enum NetworkingError: Error, Sendable {
    case invalidRequestURL
    case unexpectedError
}
