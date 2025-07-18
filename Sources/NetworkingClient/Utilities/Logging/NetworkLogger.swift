//
//  NetworkLogger.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import OSLog
import NetworkingCore

/// Logger for tracking network requests, responses, and errors.
extension NetworkLogger {
    /// Logs the start of a network request, including its `cURL` representation.
    ///
    /// - Parameters:
    ///   - request: The ``URLRequest`` being sent.
    ///   - id: A unique identifier for the request.
    package static func logStarted(request: borrowing URLRequest, id: String) {
        let cURL = CURLLogFactory.make(for: request)
        logger.debug(
            """
            ┌────────────────────────────────────────────
            │ Request Started — ID: \(id)
            │
            \(cURL)
            └────────────────────────────────────────────
            """
        )
    }
    
    /// Logs the completion of a network request, including the URL and any errors.
    ///
    /// - Parameters:
    ///   - request: The ``URLRequest`` that was sent.
    ///   - id: A unique identifier for the request.
    ///   - error: An optional ``Error`` if the request failed.
    package static func logFinished(
        request: URLRequest,
        id: String,
        error: NetworkingError?
    ) {
        let url = request.url?.absoluteString ?? "unknown"
        let errorDescription = error.map({"\n│ Error: \($0)"}) ?? ""
        let level: OSLogType = error == nil ? .debug : .error
        logger.log(level: level,
            """
            ┌────────────────────────────────────────────
            │ Request Finished — ID: \(id)
            │ URL: \(url) \(errorDescription)
            └────────────────────────────────────────────
            """
        )
    }
    
    /// Logs received data from a network response, including its status code and content.
    ///
    /// - Parameters:
    ///   - data: The received response body as ``Data``.
    ///   - status: The ``ResponseStatus`` associated with the response.
    package static func logReceived(
        data: Data,
        status: ResponseStatus?,
        id: String
    ) {
        let statusLine = status.map({"\n│ Status: \($0.rawValue)"}) ?? ""
        let bodyPreview = DataLogFactory.make(for: data)
        
        logger.debug(
            """
            ┌────────────────────────────────────────────
            │ Response Received — ID: \(id) \(statusLine)
            │
            \(bodyPreview)
            └────────────────────────────────────────────
            """
        )
    }
}
