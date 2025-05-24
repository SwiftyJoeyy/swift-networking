//
//  JSONError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension NetworkingError {
    public enum JSONError: Error, Sendable {
        case serializationFailed(dictionary: Dictionary<String, any Sendable>, error: any Error)
        case invalidObject(dictionary: Dictionary<String, any Sendable>)
        case encodingFailed(any Error)
    }
}
