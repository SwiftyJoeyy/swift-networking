//
//  ResponseInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

public protocol ResponseInterceptor: Sendable {
    typealias Context = InterceptorContext
    
    func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws -> RequestContinuation
}

public enum RequestContinuation: Sendable {
    case `continue`
    case failure(any Error)
    case retry
}

public struct InterceptorContext: Sendable {
    public let configurations: ConfigurationValues
    public let status: ResponseStatus?
    public let retryCount: Int
    public let urlRequest: URLRequest?
    
    public var error: (any Error)?
    public var continuation = RequestContinuation.continue
}
