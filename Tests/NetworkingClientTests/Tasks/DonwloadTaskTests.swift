//
//  DownloadTaskTests.swift
//  Networking
//
//  Created by Joe Maghzal on 6/4/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite(.tags(.tasks))
struct DownloadTaskTests {
// MARK: - Properties
    private let session = Session {
        var configs = URLSessionConfiguration.ephemeral
        configs.protocolClasses = [MockURLProtocol.self]
        return configs
    }
    
// MARK: - Tests
    @Test func executingDataTaskReturnsDataAndResponseOnSuccess() async throws {
        let requestID = "download-task-success"
        let request = TestRequest()
            .testID(requestID)
        
        let string = "Hello, this is a data test."
        let expectedStatus = ResponseStatus.ok
        await MockURLProtocol.setResult(
            .success((string.data(using: .utf8)!, expectedStatus)),
            for: requestID
        )
        
        let urlRequest = try request._makeURLRequest(with: session.configurations)
        let response = try await session
            .downloadTask(request)
            ._execute(urlRequest, session: session)
       
        let data = try #require(NSData(contentsOfFile: response.url.path) as? Data)
        let decoded = String(data: data, encoding: .utf8)
        
        #expect(decoded == string)
        #expect(response.response.status == expectedStatus)
    }
    
    @Test func executingDataTaskThrowsErrorOnFailure() async throws {
        let requestID = "download-task-failure"
        let request = TestRequest()
            .testID(requestID)
        
        let expectedError = MockURLError.errorMock
        await MockURLProtocol.setResult(
            .failure(expectedError),
            for: requestID
        )
        
        let urlRequest = try request._makeURLRequest(with: session.configurations)
        
        try await #require(performing: {
            _ = try await session
                .downloadTask(request)
                ._execute(urlRequest, session: session)
        }, throws: { error in
            return (error as NSError).domain == (expectedError as NSError).domain
        })
    }
    
    @Test func downloadTaskProgressUpdatesWhenRecivingNewProgress() async throws {
        let expectedUpdates = stride(from: 0, to: 1, by: 0.2).map({round($0 * 10) / 10})
        let task = session.downloadTask(TestRequest())
        
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            for update in expectedUpdates {
                await task._session(
                    didWriteData: 2,
                    totalBytesWritten: Int64(update * 10),
                    totalBytesExpectedToWrite: 10
                )
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            await task._finished(with: nil)
        }
        
        var progressUpdates = [Double]()
        for await progress in await task.progressStream {
            try await #require(task.progress == progress)
            progressUpdates.append(progress)
        }
        
        #expect(progressUpdates == expectedUpdates)
    }
    
    @Test func downloadTaskProgressUpdatesWhenResuming() async throws {
        let expectedUpdate = 0.5
        let task = session.downloadTask(TestRequest())
        
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await task._session(
                didResumeAtOffset: Int64(expectedUpdate * 10),
                expectedTotalBytes: 10
            )
            await task._finished(with: nil)
        }
        
        var progressUpdate = 0.0
        for await progress in await task.progressStream {
            try await #require(task.progress == progress)
            progressUpdate = progress
        }
        
        #expect(progressUpdate == expectedUpdate)
    }
    
    @Test func downloadTaskProgressIsZeroWhenTotalIsLessThanOrEqualToZero() async throws {
        do {
            let task = session.downloadTask(TestRequest())
            
            Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await task._session(
                    didWriteData: 0,
                    totalBytesWritten: 0,
                    totalBytesExpectedToWrite: 0
                )
                await task._finished(with: nil)
            }
            
            for await progress in await task.progressStream {
                try await #require(task.progress == progress)
                #expect(progress == 0)
            }
        }
        
        do {
            let task = session.downloadTask(TestRequest())
            
            Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await task._session(
                    didResumeAtOffset: 0,
                    expectedTotalBytes: 0
                )
                await task._finished(with: nil)
            }
            
            for await progress in await task.progressStream {
                try await #require(task.progress == progress)
                #expect(progress == 0)
            }
        }
    }
}
