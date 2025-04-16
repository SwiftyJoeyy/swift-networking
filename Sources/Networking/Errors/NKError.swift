//
//  NKError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public enum NKError: Error, Equatable {
    case invalidRequestURL
    case unacceptableStatusCode(ResponseStatus)
    case unauthorized
    case unexpectedError
}
