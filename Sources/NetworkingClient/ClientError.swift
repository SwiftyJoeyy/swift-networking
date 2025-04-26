//
//  ClientError.swift
//  Networking
//
//  Created by Joe Maghzal on 17/04/2025.
//

import Foundation
import NetworkingCore

extension NetworkingError {
    enum ClientError: Error {
        case unacceptableStatusCode(ResponseStatus)
        case unauthorized
    }
}
