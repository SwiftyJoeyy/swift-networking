//
//  NetworkTaskStateTests.swift
//  Networking
//
//  Created by Joe Maghzal on 22/07/2025.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite(.tags(.tasks))
struct NetworkTaskStateTests {
// MARK: - Properties
    private let session = Session {
        var configs = URLSessionConfiguration.ephemeral
        configs.protocolClasses = [MockURLProtocol.self]
        return configs
    }
    
// MARK: - Tests
    @Test func initialTaskStateIsCreated() async {
        let request = TestRequest()
        let task = session.dataTask(request)
        
        await #expect(task.state == .created)
    }
    
// MARK: - Resuming Tests
    @Test func resumingTaskUpdatesStateToRunning() async throws {
        Task {
            let requestID = "resume-updates-state"
            let request = TestRequest()
                .testID(requestID)
            await MockURLProtocol.setResult(
                (1_000_000_000, .failure(MockURLError.errorMock)),
                for: requestID
            )
            
            let task = session.dataTask(request)
            await task.resume()
            
            await #expect(task.state == .running)
        }
        
        Task {
            let requestID = "response-updates-state"
            let request = TestRequest()
                .testID(requestID)
            await MockURLProtocol.setResult(
                (1_000_000_000, .failure(MockURLError.errorMock)),
                for: requestID
            )
            
            let task = session.dataTask(request)
            Task {
                try await task.response()
            }
            try await Task.sleep(nanoseconds: 1_000_000_00)
            
            await #expect(task.state == .running)
        }
    }
    
    @Test func resumingTaskDoesNotUpdatesStateIfItWasCancelled() async throws {
        let requestID = "resume-does-not-update-state"
        let request = TestRequest()
            .testID(requestID)
        await MockURLProtocol.setResult(
            (2_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let task = session.dataTask(request)
        await task.cancel()
        await task.resume()

        await #expect(task.state != .running)
    }
    
// MARK: - Intercepting Tests
    @Test func interceptedTaskUpdatesStateToIntercepting() async throws {
        let requestID = "intercepting-updates-state"
        let request = TestRequest()
            .testID(requestID)
        await MockURLProtocol.setResult(.failure(MockURLError.errorMock),
            for: requestID
        )
        
        let task = session.dataTask(request)
            .configuration(\.taskInterceptor, DelayedInterceptor())
        await task.resume()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        await #expect(task.state == .intercepting)
    }
    
// MARK: - Suspending Tests
    @Test func suspendingTaskDoesNotUpdateStateIfItWasNotRunning() async {
        let request = TestRequest()
        
        let task = session.dataTask(request)
        let expectedState = await task.state
        
        await task.suspend()
        await #expect(task.state == expectedState)
    }
    
    @Test func suspendingTaskUpdatesStateToSuspendedIfItWasRunning() async {
        let requestID = "suspend-updates-state"
        let request = TestRequest()
            .testID(requestID)
        await MockURLProtocol.setResult(
            (1_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let task = session.dataTask(request)
        await task.resume()
        await task.suspend()
        
        await #expect(task.state == .suspended)
    }
    
// MARK: - Cancelling Tests
    @Test func cancellingTaskUpdatesStateToCancelled() async {
        let request = TestRequest()
        
        let task = session.dataTask(request)
        
        await task.cancel()
        await #expect(task.state == .cancelled)
    }
    
// MARK: - Finishing Tests
    @Test func finishingTaskUpdatesStateToCompleted() async {
        let requestID = "finishing-updates-state"
        let request = TestRequest()
            .testID(requestID)
        await MockURLProtocol.setResult(
            (1_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let task = session.dataTask(request)
        _ = try? await task.response()
        
        await #expect(task.state == .completed)
    }
    
// MARK: - Updates Stream Tests
    @Test func taskStateStreamUpdatesWhenStateIsUpdated() async throws {
        let expectedUpdates: [TaskState] = [.created, .running, .suspended, .running, .intercepting, .cancelled]
        let requestID = "state-updates-stream"
        let request = TestRequest()
            .testID(requestID)
        await MockURLProtocol.setResult(
            (1_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        
        let task = session.dataTask(request)
            .configuration(\.taskInterceptor, DelayedInterceptor())
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_00)
            await task.resume()
            await task.resume() // Should not be emitted twice.
            
            try? await Task.sleep(nanoseconds: 1_000_000_00)
            await task.suspend()
            
            try? await Task.sleep(nanoseconds: 1_000_000_00)
            await task.resume()
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await task.cancel()
            await task.cancel() // Should not be emitted twice.
        }
        
        var updates = [TaskState]()
        for await state in task.stateUpdates {
            try await #require(task.state == state)
            updates.append(state)
        }
        
        #expect(updates == expectedUpdates)
    }
}

extension NetworkTaskStateTests {
    struct DelayedInterceptor: Interceptor {
        func intercept(
            _ task: some NetworkingTask,
            for session: Session,
            with context: borrowing Context
        ) async throws(NetworkingError) -> RequestContinuation {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            return .continue
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
}
