//
//  NetworkLogger.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation
import OSLog

package enum NetworkLogger {
    package static let logger = Logger(subsystem: "package.network.kit", category: "Networking")
    
    package static func log(request: URLRequest, id: UUID) {
        let cURL = CURLLogFactory.make(for: request)
        logger.debug(
            """
            Started request \(id.uuidString):
            \(cURL)
            """
        )
    }
    package static func log(result: RequestResult, id: UUID) {
        switch result.result {
            case .success(let data):
                let log: String
                switch data {
                    case .url(let url):
                        log = url.absoluteString
                    case .data(let data):
                        log = DataLogFactory.make(for: data)
                }
                logger.debug(
                    """
                    Finished request \(id.uuidString):
                    \(result.statusCode.map({"Status Code: \($0.rawValue)"}) ?? "")
                    \(log)
                    """
                )
            case .failure(let error):
                logger.debug(
                    """
                    Finished request \(id.uuidString):
                    \(result.statusCode.map({"Status Code: \($0.rawValue)"}) ?? "")
                    \(error)
                    """
                )
        }
    }
}
