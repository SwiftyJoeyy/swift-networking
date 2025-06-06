//
//  SessionDelegateTests.swift
//  Networking
//
//  Created by Joe Maghzal on 6/4/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite struct SessionDelegateTests {
// MARK: - Properties
    private let request = URLRequest(url: URL(string: "https://www.google.com")!)
    private let urlSession = URLSession.shared
    private let tasks = MockTasksStorage()
    private let delegate = SessionDelegate()
    private let task: MockTask
    
    init() async {
        task = MockTask(request: request)
        await tasks.add(task, for: request)
        delegate.tasks = tasks
    }
    
// MARK: - Tests
    @Test func urlSessionDidBecomeInvalidWithErrorCallsCancelAll() async throws {
        delegate.urlSession(urlSession, didBecomeInvalidWithError: nil)
        try await Task.sleep(nanoseconds: 100_000_000)
        await #expect(tasks.cancelled == true)
    }
    
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    @Test func urlSessionDidCreateTaskCallsSet() async {
        let urlSessionDataTask = urlSession.dataTask(with: request)
        delegate.urlSession(urlSession, didCreateTask: urlSessionDataTask)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        await #expect(task.taskSet == urlSessionDataTask)
    }
    
//    @Test func urlSessionWillPerformHTTPRedirectionRedirects() async {
//        let handler = DefaultRedirectionHandler { _, _, _ in
//            return .redirect
//        }
//        networkingTask.configurations.redirectionHandler = handler
//        let task = MockURLSessionTask(request: request)
//        let response = HTTPURLResponse()
//        let redirected = await delegate.urlSession(
//            URLSession.shared, task: task,
//            willPerformHTTPRedirection: response,
//            newRequest: request
//        )
//        XCTAssertEqual(redirected, request)
//    }
//    
//    func test_urlSessionWillCacheResponse_cache() async {
//        let handler = ResponseCacheHandler { _, proposed in .cache }
//        networkingTask.configurations.cacheHandler = handler
//        let dataTask = MockURLSessionDataTask(request: request)
//        let proposed = CachedURLResponse(response: URLResponse(), data: Data())
//        let cached = await delegate.urlSession(
//            URLSession.shared, dataTask: dataTask,
//            willCacheResponse: proposed
//        )
//        XCTAssertEqual(cached, proposed)
//    }
//    
//    func test_urlSessionDownloadDidWriteData_reportsProgress() async {
//        let downloadTask = MockURLSessionDownloadTask(request: request)
//        delegate.urlSession(URLSession.shared, downloadTask: downloadTask,
//                            didWriteData: 10, totalBytesWritten: 100, totalBytesExpectedToWrite: 200)
//        try? await Task.sleep(nanoseconds: 100_000_000)
//        XCTAssertTrue(networkingTask.didCallWriteProgress)
//    }
//    
//    func test_urlSessionDownloadDidResumeAtOffset_reportsResume() async {
//        let downloadTask = MockURLSessionDownloadTask(request: request)
//        delegate.urlSession(URLSession.shared, downloadTask: downloadTask,
//                            didResumeAtOffset: 20, expectedTotalBytes: 100)
//        try? await Task.sleep(nanoseconds: 100_000_000)
//        XCTAssertTrue(networkingTask.didCallResumeProgress)
//    }
}
