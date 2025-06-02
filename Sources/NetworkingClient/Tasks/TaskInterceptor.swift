//
//  TaskInterceptor.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

struct TaskInterceptor { }

extension TaskInterceptor: RequestInterceptor {
    func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws -> URLRequest {
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
        
        return urlRequest
    }
}

extension TaskInterceptor: ResponseInterceptor {
    func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws -> RequestContinuation {
        var context = copy context
        let configurations = context.configurations
        if configurations.logsEnabled, let urlRequest = context.urlRequest {
            NetworkLogger.logFinished(
                request: urlRequest,
                id: task.id,
                error: nil
            )
        }
        
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
        
        return context.continuation
    }
    
    private func handle(_ continuation: RequestContinuation, context: inout Context) {
        switch continuation {
            case .failure(let error):
                context.error = error
            case .retry:
                context.continuation = .retry
            default:
                break
        }
    }
}
