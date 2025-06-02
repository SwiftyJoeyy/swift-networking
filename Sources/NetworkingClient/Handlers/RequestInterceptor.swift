//
//  RequestInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation
import NetworkingCore

public protocol RequestInterceptor: Sendable {
    func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws -> URLRequest
}

public struct DefaultRequestInterceptor: RequestInterceptor {
    public typealias Handler = @Sendable (
        _ request: URLRequest,
        _ task: any NetworkingTask,
        _ session: Session,
        _ configurations: ConfigurationValues
    ) async throws -> URLRequest
    
    private let handler: Handler
    
    public init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    
    public func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws -> URLRequest {
        return try await handler(consume request, task, session, configurations)
    }
}

extension Configurable {
    /// Sets the interceptor used to intercept requests before they are executed.
    public func onRequest(_ interceptor: some RequestInterceptor) -> Self {
        return configuration(\.interceptor, interceptor)
    }
    
    /// Sets the interceptor used to intercept requests before they are executed.
    public func onRequest(
        _ handler: @escaping DefaultRequestInterceptor.Handler
    ) -> Self {
        return onRequest(DefaultRequestInterceptor(handler))
    }
}
