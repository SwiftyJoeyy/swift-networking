//
//  ClientError.swift
//  Networking
//
//  Created by Joe Maghzal on 17/04/2025.
//

import Foundation
import NetworkingCore

/// A specialized error representing failures originating from client-side conditions.
///
/// `ClientError` is designed to wrap errors that are not low-level transport or encoding failures,
/// but instead represent logical issues encountered during request processing, such as invalid status codes,
/// authentication refresh problems, or URL-related issues.
public enum ClientError: Error, Sendable {
    /// Indicates that the request completed but returned an error status code.
    case status(StatusError)
    
    /// Indicates that a request failed during the authentication refresh process.
    case authRefresh(NetworkingError)
    
    /// Indicates a failure related to URL resolution or transport-level configuration.
    case urlError(URLError)
}

// MARK: - LocalizedError
extension ClientError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .status(let statusError):
                return statusError.errorDescription
            case .authRefresh(let networkingError):
                return "Authentication refresh failed: \(networkingError)"
            case .urlError(let urlError):
                return urlError.localizedDescription
        }
    }
}

extension NetworkingError {
    /// Wraps a ``ClientError`` into a ``NetworkingError.custom`` case.
    ///
    /// Use this function to embed higher-level client-side errors within a ``NetworkingError`` when
    /// exposing a unified error type across layers.
    ///
    /// - Parameter error: The client-level error to wrap.
    /// - Returns: A `.custom` ``NetworkingError`` containing the provided ``ClientError``.
    package static func client(_ error: ClientError) -> NetworkingError {
        return .custom(error)
    }
    
    /// Attempts to extract a ``ClientError`` value from the current ``NetworkingError``.
    ///
    /// This property checks whether the error is a `.custom` case wrapping a ``ClientError``,
    /// and returns it if present. If the underlying error is not a ``ClientError``, this returns `nil`.
    ///
    /// Use this to inspect structured errors stored inside `.custom`.
    public var clientError: ClientError? {
        guard case .custom(let error) = self else {
            return nil
        }
        return error as? ClientError
    }
}
