//
//  NetworkLogger.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import OSLog

/// Logger for tracking network requests, responses, and errors.
package enum NetworkLogger {
    /// The ``Logger`` used for logging network events.
    package static let logger = Logger(
        subsystem: "package.swift-networking",
        category: "Networking"
    )
    
    /// Logs a notice when a GET request includes a body,
    /// which is not supported by ``URLRequest``.
    ///
    /// - Parameters:
    ///   - id: A unique identifier associated with the request.
    ///   - url: The target URL of the GET request.
    package static func logGETRequestWithBody(id: String, url: URL?) {
        let urlPreview = url.map({"to \($0.absoluteString)"}) ?? ""
        logger.info("Discarded HTTP body from GET request (id: \(id)) \(urlPreview)")
    }
}
