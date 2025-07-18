//
//  NetworkTaskTests.swift
//  Networking
//
//  Created by Joe Maghzal on 6/2/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite(.tags(.tasks))
struct NetworkTaskTests {
// MARK: - Properties
    private let session = Session {
        var configs = URLSessionConfiguration.ephemeral
        configs.protocolClasses = [MockURLProtocol.self]
        return configs
    }
    
// MARK: - NetworkTask Tests
    @Test func taskConfigurationsAreSet() async throws {
        let baseURL = URL(string: "https://example.com")
        
        let task = session.dataTask(TestRequest())
            .configuration(\.baseURL, baseURL)
        
        #expect(task.configurations.baseURL == baseURL)
    }
    
    @Test func settingMetricsForTask() async throws {
        let requestID = "expect-metrics"
        let request = TestRequest()
            .testID(requestID)
        
        let response = ("Hello, this is a test.".data(using: .utf8)!, ResponseStatus.accepted)
        await MockURLProtocol.setResult(.success(response), for: requestID)
        
        let task = session.dataTask(request)
        _ = try await task.response()
        
        await #expect(task.metrics != nil)
    }
    
    @Test func taskReturnsExpectedData() async throws {
        let requestID = "expect-data"
        let request = TestRequest()
            .testID(requestID)
        
        let string = "Hello, this is a test."
        let response = (string.data(using: .utf8)!, ResponseStatus.accepted)
        await MockURLProtocol.setResult(.success(response), for: requestID)
        
        let data = try await session.dataTask(request)
            .response()
            .0
        let decoded = String(data: data, encoding: .utf8)
        #expect(decoded == string)
    }
    
    @Test(arguments: [ResponseStatus.accepted, ResponseStatus.badRequest])
    func taskReturnsExpectedData(expectedStatus: ResponseStatus) async throws {
        let requestID = "expect-status\(expectedStatus.rawValue)"
        let request = TestRequest()
            .testID(requestID)
        
        let response = (Data(), expectedStatus)
        await MockURLProtocol.setResult(.success(response), for: requestID)
        
        let status = try await session.dataTask(request)
            .response()
            .1.status
        #expect(status == expectedStatus)
    }
    
    @Test func taskReturnsExpectedError() async throws {
        let expectedError = MockURLError.errorMock
        let requestID = "expect-error"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(.failure(expectedError), for: requestID)
        
        try await #require(performing: {
            _ = try await session
                .dataTask(request)
                .response()
        }, throws: { networkingError in
            guard case NetworkingError.custom(let error) = networkingError else {
                return false
            }
            return (error as NSError).domain == (expectedError as NSError).domain
        })
    }
    
    @Test func resumeRunsTask() async throws {
        let requestID = "resume-runs-task"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            .failure(MockURLError.errorMock),
            for: requestID
        )
        let task = session.dataTask(request)
        
        await task.resume()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let executed = await MockURLHandler.shared.executedRequests[requestID]
        #expect(executed != nil)
    }
    
    @Test func taskIsStoredInStorageWhenTaskStarts() async throws {
        let requestID = "store-task"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (4_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        let task = session.dataTask(request)
        
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let urlRequest = try #require(await task.urlRequest)
        let stored = await session.configurations.tasks.task(for: urlRequest)
        #expect(stored?.id == task.id)
    }
    
    @Test func taskIsRemovedFromStorageWhenTaskEnds() async throws {
        let requestID = "remove-task"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            .failure(MockURLError.errorMock),
            for: requestID
        )
        let task = session.dataTask(request)
        
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let urlRequest = try #require(await task.urlRequest)
        await task.cancel()
        
        let stored = await session.configurations.tasks.task(for: urlRequest)
        #expect(stored == nil)
    }
    
    @Test func taskCancellationWhenCallingCancel() async throws {
        let requestID = "expect-cancellation-error"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (4_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        let task = session.dataTask(request)
        
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await task.cancel()
        
        let networkingError = try await #require(throws: NetworkingError.self) {
            _ = try await task.response()
        }
        var foundCorrectError = false
        if case NetworkingError.cancellation = networkingError {
            foundCorrectError = true
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
    }
    
    @Test func requestIsInterceptedBeforeExecution() async throws {
        let requestID = "intercepted-request"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (100_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let interceptor = MockRequestInterceptor { _, request, _, _ in
            var request = request
            request.setValue("true", forHTTPHeaderField: "intercepted")
            return request
        }
        let task = session
            .configuration(\.interceptor, interceptor)
            .dataTask(request)
        
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let urlRequest = try #require(await task.urlRequest)
        #expect(urlRequest.value(forHTTPHeaderField: "intercepted") == "true")
        
        let executedRequest = try #require(await MockURLHandler.shared.executedRequests[requestID])
        #expect(executedRequest.value(forHTTPHeaderField: "intercepted") == "true")
    }
    
    @Test func settingURLSessionTaskForTask() async throws {
        let requestID = "setting-urlSessionTask"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (100_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let task = session.dataTask(request)
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        await #expect(task.sessionTask != nil)
    }
    
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    @Test func susspendingURLSessionTask() async throws {
        let requestID = "suspending-urlSessionTask"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (4_000_000_000, .success((Data(), .ok))),
            for: requestID
        )
        
        let task = session.dataTask(request)
        await task.resume()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        await task.suspend()
        
        await #expect(task.sessionTask?.state == .suspended)
    }
    
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    @Test func resumingSuspendedTaskDoesNotCreateANewOne() async throws {
        let requestID = "resume-suspended-task"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (4_000_000_000, .success((Data(), .ok))),
            for: requestID
        )
        
        let task = session.dataTask(request)
        let resultTask = Task {
            try await task.response()
        }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await task.suspend()
        let urlSessionTask = try #require(await task.sessionTask)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await task.resume()
        
        await #expect(task.sessionTask === urlSessionTask)
        
        let result = try await resultTask.value
        #expect(result.1.status == .ok)
    }
    
    @Test func taskThrowsErrorWhenInterceptorReturnsFailure() async throws {
        let requestID = "task-interceptor-failure"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            .success((Data(), .ok)),
            for: requestID
        )
        
        let interceptor = MockInterceptor { task, session, context in
            return .failure(MockURLError.errorMock)
        }
        
        let networkingError = try await #require(throws: NetworkingError.self) {
            _ = try await session
                .configuration(\.taskInterceptor, interceptor)
                .dataTask(request)
                .response()
        }
        var foundCorrectError = false
        if case NetworkingError.custom(let error) = networkingError {
            foundCorrectError = (error as? MockURLError) == .errorMock
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
    }
    
    @Test func taskReturnsResultWhenInterceptorReturnsContinue() async throws {
        let requestID = "task-interceptor-result"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            .success((Data(), .ok)),
            for: requestID
        )
        
        let interceptor = MockInterceptor { task, session, context in
            return .continue
        }
        
        let data = try await session
            .configuration(\.taskInterceptor, interceptor)
            .dataTask(request)
            .response()
        
        #expect(data.1.status == .ok)
    }
    
    @Test func taskRetriesWhenInterceptorReturnsRetry() async throws {
        let requestID = "task-interceptor-result"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            .success((Data(), .ok)),
            for: requestID
        )
        
        let interceptor = MockInterceptor { task, session, context in
            if await task.retryCount == 0 {
                return .retry
            }
            return .continue
        }
        
        let task = session
            .configuration(\.taskInterceptor, interceptor)
            .dataTask(request)
        let data = try await task.response()
        
        #expect(await task.retryCount == 1)
        #expect(data.1.status == .ok)
    }
}

struct MockRequestInterceptor: RequestInterceptor {
    let handler: @Sendable (any NetworkingTask, consuming URLRequest, Session, ConfigurationValues) -> URLRequest
    func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest {
        return handler(task, consume request, session, configurations)
    }
}

struct MockInterceptor: Interceptor {
    let handler: @Sendable (any NetworkingTask, Session, Context) async throws -> RequestContinuation
    func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws(NetworkingError) -> RequestContinuation {
        do {
            return try await handler(task, session, context)
        }catch {
            throw error.networkingError
        }
    }
    
    func intercept(
        _ task: some NetworkingTask,
        request: consuming URLRequest,
        for session: Session,
        with configurations: ConfigurationValues
    ) async throws(NetworkingError) -> URLRequest {
        return request
    }
}

extension Tag {
    @Tag internal static var tasks: Self
}
