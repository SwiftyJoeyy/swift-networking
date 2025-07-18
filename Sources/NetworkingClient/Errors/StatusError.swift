//
//  StatusError.swift
//  Networking
//
//  Created by Joe Maghzal on 12/07/2025.
//

import Foundation

/// An error representing a failed HTTP response based on its status code.
///
/// `StatusError` provides a typed representation of common HTTP failure responses,
/// enabling structured error handling based on server-returned status codes.
///
/// Use this type to capture client (4xx) and server (5xx) response failures
/// when a request completes but the response is considered unsuccessful.
public enum StatusError: Error, Sendable, Equatable, Hashable {
    /// The server returned a 400 Bad Request status code.
    ///
    /// This usually indicates that the request was malformed or missing required parameters.
    case badRequest
    
    /// The server returned a 401 Unauthorized status code.
    ///
    /// This typically occurs when authentication credentials are missing, expired, or invalid.
    case unauthorized
    
    /// The server returned a 403 Forbidden status code.
    ///
    /// This indicates that the client is authenticated but does not have permission to access the requested resource.
    case forbidden
    
    /// The server returned a 404 Not Found status code.
    ///
    /// This means that the requested resource could not be found.
    case notFound
    
    /// The server returned a 409 Conflict status code.
    ///
    /// This typically occurs when there is a versioning or state conflict during resource updates.
    case conflict
    
    /// The server returned a 429 Too Many Requests status code.
    ///
    /// This indicates that the client has exceeded the rate limit for making requests.
    case tooManyRequests
    
    /// The server returned a 500 Internal Server Error status code.
    ///
    /// This is a generic error indicating that something went wrong on the server side.
    case internalServerError
    
    /// The server returned a 503 Service Unavailable status code.
    ///
    /// This typically indicates that the server is temporarily down or under heavy load.
    case serviceUnavailable
    
    /// The server returned a 504 Gateway Timeout status code.
    ///
    /// This means that the server, acting as a gateway or proxy, did not receive a timely response from an upstream server.
    case gatewayTimeout
    
    /// The server returned an unexpected or unmapped status code.
    ///
    /// Use this to handle cases where the status code is not explicitly modeled by a predefined case.
    case unknown(status: ResponseStatus)

    /// Initializes a `StatusError` from a given `ResponseStatus` value.
    ///
    /// This initializer maps well-known status codes (such as `.unauthorized`, `.notFound`, etc.)
    /// to their corresponding `StatusError` cases. If the status is not recognized, it is wrapped in `.unknown`.
    ///
    /// - Parameter status: The response status code received from the server.
    public init(status: ResponseStatus) {
        switch status {
            case .badRequest:
                self = .badRequest
            case .unauthorized:
                self = .unauthorized
            case .forbidden:
                self = .forbidden
            case .notFound:
                self = .notFound
            case .conflict:
                self = .conflict
            case .tooManyRequests:
                self = .tooManyRequests
            case .internalServerError:
                self = .internalServerError
            case .serviceUnavailable:
                self = .serviceUnavailable
            case .gatewayTimeout:
                self = .gatewayTimeout
            default:
                self = .unknown(status: status)
        }
    }
    
    /// The underlying `ResponseStatus` value that caused this error.
    ///
    /// This property exposes the original response status regardless of whether it was a known or unknown case.
    public var status: ResponseStatus {
        switch self {
            case .badRequest:
                return .badRequest
            case .unauthorized:
                return .unauthorized
            case .forbidden:
                return .forbidden
            case .notFound:
                return .notFound
            case .conflict:
                return .conflict
            case .tooManyRequests:
                return .tooManyRequests
            case .internalServerError:
                return .internalServerError
            case .serviceUnavailable:
                return .serviceUnavailable
            case .gatewayTimeout:
                return .gatewayTimeout
            case .unknown(let status):
                return status
        }
    }
}

// MARK: - LocalizedError
extension StatusError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .badRequest:
                return "The request was malformed or invalid."
            case .unauthorized:
                return "Authentication is required or has failed."
            case .forbidden:
                return "Access to the requested resource is forbidden."
            case .notFound:
                return "The requested resource could not be found."
            case .conflict:
                return "The request could not be completed due to a conflict with the current state of the resource."
            case .tooManyRequests:
                return "You have made too many requests in a short period of time."
            case .internalServerError:
                return "The server encountered an internal error."
            case .serviceUnavailable:
                return "The server is currently unavailable. Please try again later."
            case .gatewayTimeout:
                return "The server took too long to respond."
            case .unknown(let status):
                return "Received an unknown status code: \(status.rawValue)."
        }
    }
}
