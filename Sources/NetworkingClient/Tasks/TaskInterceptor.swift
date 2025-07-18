//
//  TaskInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

/// An internal coordinator that applies all configured request and response interceptors.
///
/// `TaskInterceptor` performs the final composition of request and response pipeline logic,
/// including authentication, retry, and validation steps. It acts as both a
/// ``RequestInterceptor`` and a ``ResponseInterceptor``, invoking other interceptors
/// configured in ``ConfigurationValues``.
///
/// This type is used internally by the task execution engine to process
/// preflight mutations and post-response behaviors such as retrying or failing.
internal struct TaskInterceptor: Interceptor {
    /// Composes and applies all configured request interceptors.
    ///
    /// This method first applies the custom ``ConfigurationValues/interceptor``, if present,
    /// followed by ``ConfigurationValues/authInterceptor`` for authorization injection.
    ///
    /// It also logs the final request if logging is enabled via
    /// ``ConfigurationValues/logsEnabled``.
    ///
    /// - Parameters:
    ///   - task: The current networking task.
    ///   - request: The initial ``URLRequest``, constructed from the base request.
    ///   - session: The session executing the request.
    ///   - configurations: The current configuration values.
    ///
    /// - Returns: The final ``URLRequest`` to send.
    internal func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest {
        var urlRequest = consume request
        
        if let interceptor = configurations.interceptor {
            urlRequest = try await interceptor.intercept(
                task,
                request: consume urlRequest,
                for: session,
                with: configurations
            )
        }
        
        if let authInterceptor = configurations.authInterceptor {
            urlRequest = try await authInterceptor.intercept(
                task,
                request: consume urlRequest,
                for: session,
                with: configurations
            )
        }
        
        if configurations.logsEnabled {
            NetworkLogger.logStarted(request: urlRequest, id: task.id)
        }
        
        return urlRequest
    }
    
    /// Composes and evaluates response interceptors after the request completes.
    ///
    /// This method applies response interceptors in the following order:
    /// 1. ``ConfigurationValues/statusValidator``
    /// 2. ``ConfigurationValues/authInterceptor`` (if present)
    /// 3. ``ConfigurationValues/retryPolicy``
    ///
    /// It also logs the finished request if logging is enabled via
    /// ``ConfigurationValues/logsEnabled``.
    ///
    /// Interceptors are short-circuited: if any interceptor returns `.failure` or `.retry`,
    /// the context is updated and returned early.
    ///
    /// - Parameters:
    ///   - task: The networking task being evaluated.
    ///   - session: The executing session.
    ///   - context: The response context, including configuration, status, and error.
    ///
    /// - Returns: A continuation value indicating whether to proceed, fail, or retry.
    internal func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws(NetworkingError) -> RequestContinuation {
        var context = copy context
        let configurations = context.configurations
        
        if let statusValidator = configurations.statusValidator {
            let cont = try await statusValidator.intercept(task, for: session, with: context)
            handle(cont, context: &context)
        }
        
        if let authInterceptor = configurations.authInterceptor {
            let cont = try await authInterceptor.intercept(task, for: session, with: context)
            handle(cont, context: &context)
        }
        
        if let retryPolicy = configurations.retryPolicy {
            let cont = try await retryPolicy.intercept(task, for: session, with: context)
            handle(cont, context: &context)
        }

        if configurations.logsEnabled, let urlRequest = context.urlRequest {
            NetworkLogger.logFinished(
                request: urlRequest,
                id: task.id,
                error: context.error
            )
        }
        
        return context.continuation
    }
    
    /// Updates the context based on the returned continuation.
    private func handle(_ continuation: RequestContinuation, context: inout Context) {
        switch continuation {
            case .failure(let error):
                context.error = error.networkingError
            case .retry:
                context.continuation = .retry
            default:
                break
        }
    }
}
