//
//  SerializationError.swift
//  Networking
//
//  Created by Joe Maghzal on 12/07/2025.
//

import Foundation

extension NetworkingError {
    public enum SerializationError: Error, Sendable {
        /// Thrown when a dictionary could not be serialized into JSON.
        ///
        /// - Parameters:
        ///   - dictionary: The dictionary that failed to serialize.
        ///   - error: The underlying error that occurred during serialization.
        case serializationFailed(
            dictionary: [String: any Sendable],
            error: any Error
        )
        
        /// Thrown when a dictionary contains non-serializable values.
        ///
        /// This typically occurs when the dictionary includes types that are not valid JSON values,
        /// such as ``Date`` or custom objects.
        case invalidObject(dictionary: [String: any Sendable])
    }
}

extension NetworkingError.SerializationError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .serializationFailed(_, let error):
                return "Failed to serialize dictionary to JSON. \(error.localizedDescription)"
            case .invalidObject:
                return "The dictionary contains values that are not valid JSON types."
        }
    }
}
