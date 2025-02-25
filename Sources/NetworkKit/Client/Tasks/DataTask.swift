//
//  DataTask.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

public typealias DataResponse = (data: Data, response: URLResponse)

open class DataTask: NetworkTask<DataResponse>, @unchecked Sendable {
    open override func task(
        for request: borrowing URLRequest,
        session: URLSession
    ) async throws -> DataResponse {
        let response = try await session.data(for: request)
        let status = response.1.status
        try Task.checkCancellation()
        if let status {
            let validator = await configurations.handlers.statusValidator
            try await validator.validate(self, status: status)
        }
        await NetworkLogger.logReceived(data: response.0, status: status, logsEnabled: configurations.logsEnabled)
        return response
    }
    
    open func response() async throws -> DataResponse {
        return try await activeTask().value
    }
    open func decode<T: Decodable>(
        as type: T.Type,
        using decoder: JSONDecoder? = nil
    ) async throws -> sending T {
        let response = try await response()
        var taskDecoder = await configurations.decoder
        taskDecoder = decoder ?? taskDecoder
        return try taskDecoder.decode(T.self, from: response.data)
    }
}
