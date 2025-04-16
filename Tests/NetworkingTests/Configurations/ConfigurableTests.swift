//
//  ConfigurableTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
@testable import Networking

@Suite(.tags(.configurations))
struct ConfigurableTests {
    @Test func urlConfiguration() {
        let url = URL(string: "https://example.com")!
        let configured = TestConfigurable().baseURL(url)
        #expect(configured.configurationValues.baseURL == url)
    }
    
    @Test func urlStringConfiguration() {
        let urlString = "https://string-url.com"
        let configured = TestConfigurable().baseURL(urlString)
        #expect(configured.configurationValues.baseURL == URL(string: urlString))
    }

    @Test func encoderConfiguration() {
        let encoder = JSONEncoder()
        let configured = TestConfigurable().encode(with: encoder)
        #expect(configured.configurationValues.encoder === encoder)
    }

    @Test func decoderConfiguration() {
        let decoder = JSONDecoder()
        let configured = TestConfigurable().decode(with: decoder)
        #expect(configured.configurationValues.decoder === decoder)
    }

    @Test func enableLogsConfiguration() {
        let configured = TestConfigurable().enableLogs(true)
        #expect(configured.configurationValues.logsEnabled)

        let disabled = TestConfigurable().enableLogs(false)
        #expect(!disabled.configurationValues.logsEnabled)
    }

    @Test func interceptorConfiguration() {
        let interceptor = DummyInterceptor()
        let configured = TestConfigurable().interceptor(interceptor)
        #expect(configured.configurationValues.interceptor is DummyInterceptor)
    }

    @Test func onRequestInterceptor() {
        let configured = TestConfigurable()
            .onRequest { request, task, session in
                return request
            }
        #expect(configured.configurationValues.interceptor is DefaultRequestInterceptor)
    }

    @Test func retryPolicyConfiguration() {
        let retry = DummyRetryPolicy()
        let configured = TestConfigurable().retryPolicy(retry)
        #expect(configured.configurationValues.retryPolicy is DummyRetryPolicy)
    }

    @Test func retryDefaultConfiguration() {
        let statuses: Set<ResponseStatus> = [.notFound, .tooManyRequests]
        let configured = TestConfigurable().retry(limit: 3, for: statuses)
        #expect(configured.configurationValues.retryPolicy is DefaultRetryPolicy)
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
        let validator = DummyStatusValidator()
        let configured = TestConfigurable().statusValidator(validator)
        #expect(configured.configurationValues.statusValidator is DummyStatusValidator)
    }

    @Test func validateDefaultStatusValidator() {
        let statuses: Set<ResponseStatus> = [.ok, .created]
        let configured = TestConfigurable().validate(for: statuses)
        #expect(configured.configurationValues.statusValidator is DefaultStatusValidator)
    }

    @Test func authorizationHandlerConfiguration() {
        let interceptor = DummyAuthInterceptor()
        let configured = TestConfigurable().authorization(interceptor)
        #expect(configured.configurationValues.authHandler is DummyAuthInterceptor)
    }
}

extension ConfigurableTests {
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
    struct DummyInterceptor: RequestInterceptor {
        func intercept(
            _ request: consuming URLRequest,
            for task: some NetworkingTask,
            with session: Session
        ) async throws -> URLRequest {
            return request
        }
    }
    struct DummyRetryPolicy: RetryPolicy {
        var maxRetryCount = 2
        
        func shouldRetry(
            _ task: some NetworkingTask,
            error: (any Error)?,
            status: ResponseStatus?
        ) async -> RetryResult {
            return .retry
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
        var validStatuses: Set<Networking.ResponseStatus> = []
        
        func validate(
            _ task: some NetworkingTask,
            status: ResponseStatus
        ) async throws { }
    }
    
    struct DummyAuthInterceptor: AuthenticationInterceptor {
        var credential = DummyCredential()
        
        func refresh(with session: Session) async throws {
        }
    }
    
    struct DummyCredential: AuthCredential {
        func requiresRefresh() -> Bool {
            return false
        }
        func modifying(
            _ request: consuming URLRequest,
            with configurations: borrowing ConfigurationValues
        ) throws -> URLRequest {
            return request
        }
    }
}
