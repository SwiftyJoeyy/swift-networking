//
//  NKError.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public enum NKError: Error {
    case invalidRequestURL
    case unacceptableStatusCode(ResponseStatus)
}
