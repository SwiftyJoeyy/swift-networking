//
//  NetworkLogger.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import OSLog

package enum NetworkLogger {
    package static let logger = Logger(subsystem: "package.network.kit", category: "Networking")
    
    package static func logStarted(task: any NetworkingTask, logsEnabled: Bool) {
        guard logsEnabled else {return}
        let cURL = CURLLogFactory.make(for: task.request)
        logger.debug(
            """
            --------------------------------
            Started Request: \(task.id):
            \(cURL)
            --------------------------------
            """
        )
    }
    package static func logFinished(
        task: any NetworkingTask,
        error: (any Error)?,
        logsEnabled: Bool
    ) {
        guard logsEnabled else {return}
        let errorDescription = error.map({"Error: \(String(describing: $0))"}) ?? ""
        logger.debug(
            """
            --------------------------------
            Finished Request: \(task.id):
            \(task.request.url?.absoluteString ?? "")
            \(errorDescription)
            --------------------------------
            """
        )
    }
    package static func logReceived(
        data: Data,
        status: ResponseStatus?,
        logsEnabled: Bool
    ) {
        guard logsEnabled else {return}
        let log = DataLogFactory.make(for: data)
        logger.debug(
            """
            \(status.map({"Status Code: \($0.rawValue) ()"}) ?? "")
            \(log)
            """
        )
        
    }
}
