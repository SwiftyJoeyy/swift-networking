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
package enum NetworkLogger {
    /// The ``Logger`` used for logging network events.
    package static let logger = Logger(
        subsystem: "package.swift-networking",
        category: "Networking"
    )
    
    /// Logs the start of a network request, including its `cURL` representation.
    ///
    /// - Parameters:
    ///   - request: The ``URLRequest`` being sent.
    ///   - id: A unique identifier for the request.
    package static func logStarted(request: borrowing URLRequest, id: String) {
        let cURL = CURLLogFactory.make(for: request)
        logger.debug(
            """
            --------------------------------
            Started Request: \(id):
            \(cURL)
            --------------------------------
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
        error: (any Error)?
    ) {
        let errorDescription = error.map({"Error: \(String(describing: $0))"}) ?? ""
        logger.debug(
            """
            --------------------------------
            Finished Request: \(id) - \(request.url?.absoluteString ?? "")
            \(errorDescription)
            --------------------------------
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
        let log = DataLogFactory.make(for: data)
        logger.debug(
            """
            --------------------------------
            Request \(id) - \(status.map({"Status Code: \($0.rawValue)"}) ?? ""):
            \(log)
            --------------------------------
            """
        )
    }
}
