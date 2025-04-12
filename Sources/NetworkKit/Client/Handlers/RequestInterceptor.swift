//
//  RequestInterceptor.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation

public protocol RequestInterceptor: Sendable {
    func intercept(
        _ request: consuming URLRequest,
        for task: some NetworkingTask,
        with session: Session
    ) async throws -> URLRequest
}

extension RequestInterceptor where Self == DefaultRequestInterceptor {
    public static var none: Self {
        return DefaultRequestInterceptor()
    }
}

public struct DefaultRequestInterceptor: RequestInterceptor {
    public typealias Handler = @Sendable (
        _ request: URLRequest,
        _ task: any NetworkingTask,
        _ session: Session
    ) async throws -> URLRequest
    
// MARK: - Properties
    private let handler: Handler?
    
// MARK: - Initializer
    internal init(_ handler: Handler? = nil) {
        self.handler = handler
    }
    
// MARK: - TaskStartHandler
    public func intercept(
        _ request: consuming URLRequest,
        for task: some NetworkingTask,
        with session: Session
    ) async throws -> URLRequest {
        guard let handler else {
            return request
        }
        return try await handler(consume request, task, session)
    }
}
