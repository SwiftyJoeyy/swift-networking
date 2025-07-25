//
//  DataTask.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation
import NetworkingCore

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
    ///   - session: The session used to perform the request.
    ///
    /// - Returns: The response containing the raw data and HTTP response.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    /// - Note: This method is prefixed with `_` to indicate that it is not intended for public use.
    open override func _execute(
        _ urlRequest: borrowing URLRequest,
        session: Session
    ) async throws(NetworkingError) -> DataResponse {
        do {
            let response = try await session.session.data(
                for: urlRequest,
                delegate: session.delegate
            )
            let status = response.1.status
            if configurations.logsEnabled {
                await NetworkLogger.logReceived(
                    data: response.0,
                    status: status,
                    id: request.id
                )
            }
            return response
        }catch let error as URLError {
            throw .client(.urlError(error))
        }catch {
            throw .custom(error)
        }
    }
    
    /// Decodes the response data into a specified ``Decodable`` type.
    ///
    /// - Parameter type: The ``Decodable`` type to decode the data into.
    /// - Returns: The decoded object of type `T`.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    open func decode<T: Decodable>(as type: T.Type) async throws(NetworkingError) -> (sending T) {
        let response = try await response()
        let decoder = configurations.decoder
        do {
            return try decoder.decode(T.self, from: response.0)
        }catch let error as DecodingError {
            throw .decoding(error)
        }catch {
            throw .custom(error)
        }
    }
}
