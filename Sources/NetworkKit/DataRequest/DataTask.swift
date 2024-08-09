//
//  DataTask.swift
//  
//
//  Created by Joe Maghzal on 05/06/2024.
//

import Foundation

struct DataTask: RequestTask {
    func execute(
        for request: URLRequest,
        session: URLSession
    ) async -> RequestResult {
        do {
            let result = try await session.data(for: request)
            let httpResponse = result.1 as? HTTPURLResponse
            let statusCode = httpResponse.flatMap({ResponseStatus(rawValue: $0.statusCode)})
            return RequestResult(.success(.data(result.0)), statusCode: statusCode)
        }catch {
            let error = NKError.sessionError(error)
            return RequestResult(.failure(error), statusCode: nil)
        }
    }
}
