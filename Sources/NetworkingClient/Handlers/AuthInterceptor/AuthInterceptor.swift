//
//  AuthInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 3/5/25.
//

import Foundation
import NetworkingCore

/// An interceptor that manages authentication using an ``AuthProvider``.
///
/// `AuthInterceptor` applies credentials to outgoing requests and
/// refreshes them if the response indicates an authentication failure.
///
/// It acts as both a ``RequestInterceptor`` and a ``ResponseInterceptor``, enabling:
/// - Credential injection before the request is sent
/// - Automatic refresh when an unauthorized (`401`) response is received
///
/// Use this type via ``Configurable/authorization(_:)`` to automatically apply and refresh auth.
///
/// - Important: Only a single refresh task is executed at a time.
/// Concurrent requests will wait for the same refresh to complete.
public actor AuthInterceptor {
    /// The provider that handles authorization.
    private let provider: any AuthProvider
    
    /// The current refresh task.
    private var task: Task<Void, any Error>?
    
    /// Creates a new interceptor with the given authentication provider.
    ///
    /// - Parameter provider: A type conforming to ``AuthProvider``.
    public init(provider: any AuthProvider) {
        self.provider = provider
    }
    
    /// Refreshes the credentials if not already in progress.
    ///
    /// If a refresh is already ongoing, subsequent callers await its result.
    ///
    /// - Parameter session: The active session to use for refreshing.
    private func refresh(with session: Session) async throws(NetworkingError) {
        do {
            if let task {
                try await task.value
            }else {
                task = Task {
                    try await provider.refresh(with: session)
                }
                try await task?.value
            }
        }catch {
            throw .client(.authRefresh(error.networkingError))
        }
    }
}

// MARK: - RequestInterceptor
extension AuthInterceptor: RequestInterceptor {
    /// Applies the authentication credential to the outgoing request.
    ///
    /// If the provider indicates that a refresh is needed,
    /// this method refreshes the credentials before continuing.
    ///
    /// - Returns: A modified request with authentication applied.
    public func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest {
        if provider.requiresRefresh() {
            try await refresh(with: session)
        }
        return try provider.credential.modifying(consume request)
    }
}

// MARK: - ResponseInterceptor
extension AuthInterceptor: ResponseInterceptor {
    /// Intercepts unauthorized responses to trigger a credential refresh.
    ///
    /// This only runs if the response is `401 Unauthorized` and the retry count is zero.
    ///
    /// - Returns: `.retry` if refresh succeeds; otherwise `.continue` or rethrows on failure.
    public func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws(NetworkingError) -> RequestContinuation {
        guard context.status == .unauthorized, context.retryCount == 0 else {
            return .continue
        }
        
        try await refresh(with: session)
        return .retry
    }
}

extension Configurable {
    /// Disables request authorization.
    ///
    /// Call this to explicitly disable authentication for a request.
    public func unauthorized() -> Self {
        return configuration(\.authInterceptor, nil)
    }
    
    /// Sets the authorization provider used to authorize requests.
    ///
    /// The interceptor will apply credentials before sending and refresh them
    /// automatically if the response is unauthorized.
    ///
    /// - Parameter provider: A type conforming to ``AuthProvider``.
    public func authorization(
        _ provider: some AuthProvider
    ) -> Self {
        return configuration(\.authInterceptor, AuthInterceptor(provider: provider))
    }
}
