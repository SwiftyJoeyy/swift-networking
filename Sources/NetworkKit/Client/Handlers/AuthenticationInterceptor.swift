//
//  AuthenticationInterceptor.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 3/5/25.
//

import Foundation

public protocol AuthCredential: RequestModifier, Sendable {
    func requiresRefresh() -> Bool
}

public protocol AuthenticationInterceptor: RequestInterceptor, Sendable {
    associatedtype Credential: AuthCredential
    var credential: Credential {get}
    func refresh(with session: Session) async throws
}

extension AuthenticationInterceptor {
    public func intercept(
        _ request: consuming URLRequest,
        for task: some NetworkingTask,
        with session: Session
    ) async throws -> URLRequest {
        if credential.requiresRefresh() {
            try await refresh(with: session)
        }
        return try credential.modifying(
            consume request,
            with: task.configurations
        )
    }
}
