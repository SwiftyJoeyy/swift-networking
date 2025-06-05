//
//  ClientConfigurationsTests.swift
//  Networking
//
//  Created by Joe Maghzal on 17/04/2025.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite
struct ClientConfigurableTests {
    @Test func enableLogsConfiguration() {
        let configured = TestConfigurable().enableLogs(true)
        #expect(configured.configurationValues.logsEnabled)
        
        let disabled = TestConfigurable().enableLogs(false)
        #expect(!disabled.configurationValues.logsEnabled)
    }
    
    @Test func onRequestInterceptor() {
        do {
            let configured = TestConfigurable()
                .onRequest { request, task, session, configurations in
                    return request
                }
            #expect(configured.configurationValues.interceptor is DefaultRequestInterceptor)
        }
        
        do {
            let interceptor = DummyRequestInterceptor()
            let configured = TestConfigurable().onRequest(interceptor)
            #expect(configured.configurationValues.interceptor is DummyRequestInterceptor)
        }
    }
    
    @Test func retryDefaultConfiguration() {
        let statuses: Set<ResponseStatus> = [.notFound, .tooManyRequests]
        
        do {
            let interceptor = DummyRetryInterceptor()
            let configured = TestConfigurable().retry(interceptor)
            #expect(configured.configurationValues.retryPolicy is DummyRetryInterceptor)
        }
        
        do {
            let configured = TestConfigurable().retry(limit: 3, for: statuses)
            #expect(configured.configurationValues.retryPolicy is DefaultRetryInterceptor)
        }
        
        do {
            let configured = TestConfigurable().retry(limit: 3, for: statuses, delay: 10)
            #expect(configured.configurationValues.retryPolicy is DefaultRetryInterceptor)
        }
        
        do {
            let configured = TestConfigurable().retry(limit: 3, for: statuses, base: 10, multiplier: 1)
            #expect(configured.configurationValues.retryPolicy is DefaultRetryInterceptor)
        }
        
        do {
            let configured = TestConfigurable().doNotRetry()
            #expect(configured.configurationValues.retryPolicy == nil)
        }
    }
    
    @Test func cacheHandlerConfiguration() {
        let handler = DummyCacheHandler()
        let configured = TestConfigurable().cacheHandler(handler)
        #expect(configured.configurationValues.cacheHandler is DummyCacheHandler)
    }
    
    @Test func redirectionHandlerConfiguration() {
        let handler = DummyRedirecationHandler()
        let configured = TestConfigurable().redirectionHandler(handler)
        #expect(configured.configurationValues.redirectionHandler is DummyRedirecationHandler)
    }
    
    @Test func statusValidatorConfiguration() {
        do {
            let validator = DummyStatusValidator()
            let configured = TestConfigurable().validate(validator)
            #expect(configured.configurationValues.statusValidator is DummyStatusValidator)
        }
        
        do {
            let statuses: Set<ResponseStatus> = [.ok, .created]
            let configured = TestConfigurable().validate(for: statuses)
            #expect(configured.configurationValues.statusValidator is DefaultStatusValidator)
        }
        
        do {
            let configured = TestConfigurable().unvalidated()
            #expect(configured.configurationValues.statusValidator == nil)
        }
    }
    
    @Test func authorizationHandlerConfiguration() {
        do {
            let interceptor = DummyAuthProvider()
            let configured = TestConfigurable().authorization(interceptor)
            #expect(configured.configurationValues.authInterceptor != nil)
        }
        
        do {
            let configured = TestConfigurable().unauthorized()
            #expect(configured.configurationValues.authInterceptor == nil)
        }
    }
    
    @Test func settingTasksAndAccessingIt() {
        var configurations = ConfigurationValues()
        let tasks = MockTasksStorage()
        configurations.tasks = tasks
        
        #expect(configurations.tasks === tasks)
    }
}

extension ClientConfigurableTests {
    struct TestConfigurable: Configurable {
        var configurationValues = ConfigurationValues()
        
        consuming func configuration<V>(
            _ keyPath: WritableKeyPath<ConfigurationValues, V>,
            _ value: V
        ) -> TestConfigurable {
            configurationValues[keyPath: keyPath] = value
            return self
        }
    }
    struct DummyRequestInterceptor: RequestInterceptor {
        func intercept(
            _ task: some NetworkingTask,
            request: consuming URLRequest,
            for session: Session,
            with configurations: ConfigurationValues
        ) async throws -> URLRequest {
            return request
        }
    }
    struct DummyRetryInterceptor: RetryInterceptor {
        func shouldRetry(
            _ task: some NetworkingTask,
            error: any Error,
            with context: borrowing Context
        ) async -> RetryResult {
            return .doNotRetry
        }
    }
    struct DummyCacheHandler: ResponseCacheHandler {
        func cache(
            _ task: some NetworkingTask,
            proposedResponse: CachedURLResponse
        ) async -> ResponseCacheBehavior {
            return .cache
        }
    }
    struct DummyRedirecationHandler: RedirectionHandler {
        func redirect(
            _ task: some NetworkingTask,
            redirectResponse: URLResponse,
            newRequest: URLRequest
        ) async -> RedirectionBehavior {
            return .ignore
        }
    }
    struct DummyStatusValidator: StatusValidator {
        func validate(
            _ task: some NetworkingTask,
            status: ResponseStatus,
            with context: borrowing Context
        ) async throws { }
    }
    
    struct DummyAuthProvider: AuthProvider {
        var credential = DummyCredential()
        
        func refresh(with session: Session) async throws {
        }
        
        func requiresRefresh() -> Bool {
            return false
        }
    }
    
    struct DummyCredential: RequestModifier {
        func modifying(_ request: consuming URLRequest) throws -> URLRequest {
            return request
        }
    }
}
