//
//  AuthenticationInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 3/5/25.
//

import Foundation
import NetworkingCore

public actor AuthInterceptor {
    private let provider: any AuthProvider
    private var task: Task<Void, any Error>?
    
    public init(provider: any AuthProvider) {
        self.provider = provider
    }
    
    private func refresh(with session: Session) async throws {
        if let task {
            try await task.value
        }else {
            task = Task {
                try await provider.refresh(with: session)
            }
            try await task?.value
        }
    }
}

// MARK: - RequestInterceptor
extension AuthInterceptor: RequestInterceptor {
    public func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws -> URLRequest {
        if provider.requiresRefresh() {
            try await refresh(with: session)
        }
        return try provider.credential.modifying(consume request)
    }
}

// MARK: - ResponseInterceptor
extension AuthInterceptor: ResponseInterceptor {
    public func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws -> RequestContinuation {
        guard context.status == .unauthorized, context.retryCount == 0 else {
            return .continue
        }
        
        do {
            try await refresh(with: session)
        }catch {
            throw error
        }
        return .retry
    }
}

extension Configurable {
    /// Sets the handler used to manage request authorization.
    public func authorization(
        _ provider: some AuthProvider
    ) -> Self {
        return configuration(\.authInterceptor, AuthInterceptor(provider: provider))
    }
}
