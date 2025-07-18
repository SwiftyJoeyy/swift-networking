//
//  NetworkingError.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// An error that represents a failure during request creation, encoding, file handling, or stream processing.
public enum NetworkingError: Error, Sendable {
    /// A custom error provided by the caller.
    case custom(any Error)
    
    /// Indicates that cancellation has occurred at a higher level.
    /// 
    /// - Note: This is used for typed throws.
    case cancellation
    
    /// Thrown when the request URL is invalid or could not be constructed.
    case invalidRequestURL
    
    /// Thrown when an unexpected error occurs during the request lifecycle.
    case unexpectedError
    
    /// An error related to serialization or deserialization of request or response data.
    case serialization(SerializationError)
    
    /// An error related to file access or streaming.
    case file(FileError)
    
    /// Thrown when a value fails to encode due to a specific ``EncodingError``.
    case encoding(EncodingError)
    
    /// Thrown when decoding of a response fails due to a type mismatch, missing key, or invalid structure.
    case decoding(DecodingError)
}

// MARK: - LocalizedError
extension NetworkingError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .custom(let error):
                return error.localizedDescription
            case .cancellation:
                return CancellationError().localizedDescription
            case .invalidRequestURL:
                return "The request URL is invalid."
            case .unexpectedError:
                return "An unexpected error occurred."
            case .serialization(let error):
                return error.localizedDescription
            case .file(let error):
                return error.localizedDescription
            case .encoding(let error):
                return error.localizedDescription
            case .decoding(let error):
                return error.localizedDescription
        }
    }
}

extension Error {
    /// Converts the current error into a ``NetworkingError`` value.
    ///
    /// This property inspects the current error instance and maps it to an appropriate ``NetworkingError`` case:
    /// - If the error is a ``CancellationError``, it returns ``.cancellation``.
    /// - If the error is already a ``NetworkingError``, it returns the value unchanged.
    /// - Otherwise, it wraps the error in ``.custom``.
    ///
    /// Use this property to normalize errors into a consistent ``NetworkingError`` representation when handling failures in the networking layer.
    ///
    /// ```swift
    /// catch {
    ///     let error = error.networkingError
    ///     handle(error)
    /// }
    /// ```
    public var networkingError: NetworkingError {
        if self is CancellationError {
            return .cancellation
        }
        if let error = self as? NetworkingError {
            return error
        }
        return .custom(self)
    }
    
    /// Converts the current error into a ``NetworkingError``, with support for custom mapping.
    ///
    /// This function checks if the error is already a ``NetworkingError``. If so, it returns it directly.
    /// Otherwise, it applies the provided `map` function to convert the error into a ``NetworkingError``.
    ///
    /// Use this when you want to supply custom conversion logic for non-networking errors.
    ///
    /// ```swift
    /// catch {
    ///     let error = error.networkingError { error in
    ///         if let decoding = error as? DecodingError {
    ///             return .decoding(decoding)
    ///         }
    ///         return .custom(error)
    ///     }
    ///     handle(error)
    /// }
    /// ```
    ///
    /// - Parameter map: A closure that takes the current error and returns a ``NetworkingError``.
    /// - Returns: A ``NetworkingError`` representing the current error.
    package func networkingError(
        _ map: (Self) -> NetworkingError
    ) -> NetworkingError {
        if let error = self as? NetworkingError {
            return error
        }
        return map(self)
    }
}
