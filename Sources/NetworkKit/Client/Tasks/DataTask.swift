//
//  DataTask.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

public typealias DataResponse = (data: Data, response: URLResponse)

/// Task that handles making HTTP requests, validating response statuses, logging the response,
/// and decoding the data into a specified ``Decodable`` type.
///
/// ``DataTask`` inherits from ``NetworkTask``, which is
/// responsible for managing the network request, while this class adds
/// decoding functionality and handles data-related
/// logic.
open class DataTask: NetworkTask<Data>, @unchecked Sendable {
    /// Executes the network request with the provided ``URLRequest`` and session.
    ///
    /// - Parameters:
    ///   - request: The URL request to be executed.
    ///   - session: The session instance used to perform the request.
    ///
    /// - Returns: The response containing the raw data and HTTP response.
    open override func execute(
        _ request: borrowing URLRequest,
        session: Session
    ) async throws -> DataResponse {
        let response = try await session.session.data(
            for: request,
            delegate: session.delegate
        )
        let status = response.1.status
        if await configurations.logsEnabled {
            NetworkLogger.logReceived(data: response.0, status: status)
        }
        return response
    }
    
    /// Decodes the response data into a specified ``Decodable`` type.
    ///
    /// - Parameter type: The ``Decodable`` type to decode the data into.
    /// - Returns: The decoded object of type `T`.
    open func decode<T: Decodable>(
        as type: T.Type
    ) async throws -> sending T {
        let response = try await response()
        let decoder = await configurations.decoder
        return try decoder.decode(T.self, from: response.0)
    }
}
