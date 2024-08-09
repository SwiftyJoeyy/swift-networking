//
//  JSONError.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

extension NKError {
    public enum JSONError: Error {
        case serializationFailed(dictionary: Dictionary<String, Any>, error: Error)
        case encodingFailed(Error)
    }
}
