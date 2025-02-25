//
//  JSONError.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension NKError {
    public enum JSONError: Error {
        case serializationFailed(dictionary: Dictionary<String, any Sendable>, error: any Error)
        case encodingFailed(any Error)
    }
}
