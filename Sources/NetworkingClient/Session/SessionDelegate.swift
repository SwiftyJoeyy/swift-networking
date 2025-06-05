//
//  SessionDelegate.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

/// Centralized handler for networking-related delegate callbacks such as
/// redirections, caching, and progress reporting.
open class SessionDelegate: NSObject, @unchecked Sendable {
    /// Reference to the ``TasksStorage`` that manages active network tasks.
    /// Set internally by the ``Session`` and used to
    /// locate task metadata based on the original request.
    public internal(set) var tasks: (any TasksStorage)!
    
    private func networkTask(
        for sessionTask: URLSessionTask
    ) async -> (any NetworkingTask)? {
        guard let originalRequest = sessionTask.originalRequest else {
            return nil
        }
        return await tasks.task(for: originalRequest)
    }
}

// MARK: - URLSessionDelegate
extension SessionDelegate: URLSessionDelegate {
    /// Called when the session becomes invalid, typically due to errors or explicit invalidation.
    open func urlSession(
        _ session: URLSession,
        didBecomeInvalidWithError error: (any Error)?
    ) {
        Task {
            await tasks.cancelAll()
        }
    }
}

// MARK: - URLSessionTaskDelegate
extension SessionDelegate: URLSessionTaskDelegate {
    /// Called when a new ``URLSessionTask`` is created in the provided ``URLSession``.
    /// This method is responsible for associating the created task with a corresponding network task.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    open func urlSession(
        _ session: URLSession,
        didCreateTask task: URLSessionTask
    ) {
        Task {
            let nTask = await networkTask(for: task)
            await nTask?._set(task)
        }
    }
    
    /// Called when the session is about to perform an HTTP redirection.
    ///
    /// Uses a configured ``RedirectionHandler`` to determine whether to follow the redirection,
    /// ignore it, or modify the request.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        guard let task = await networkTask(for: task)
        else {
            return request
        }
        let behavior = await task.configurations.redirectionHandler.redirect(
            task,
            redirectResponse: response,
            newRequest: request
        )
        switch behavior {
        case .redirect:
            return request
        case .ignore:
            return nil
        case .modified(let newRequest):
            return newRequest
        }
    }
    
    /// Called when metrics have been collected for a task.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        Task {
            let task = await networkTask(for: task)
            await task?._session(collected: metrics)
        }
    }
    
    //TODO: - Implement for ssl pinning
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.performDefaultHandling, nil)
    }
}

// MARK: - URLSessionDataDelegate
extension SessionDelegate: URLSessionDataDelegate {
    /// Called when a data task is about to cache a response.
    ///
    /// Uses a configured ``ResponseCacheHandler`` to determine whether to cache the response,
    /// ignore it, or use a modified cached response.
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse
    ) async -> CachedURLResponse? {
        guard let task = await networkTask(for: dataTask) else {
            return proposedResponse
        }
        let handler = task.configurations.cacheHandler
        let behavior = await handler.cache(task, proposedResponse: proposedResponse)
        switch behavior {
        case .cache:
            return proposedResponse
        case .ignore:
            return nil
        case .modified(let response):
            return response
        }
    }
}

// MARK: - URLSessionDownloadDelegate
extension SessionDelegate: URLSessionDownloadDelegate {
    /// Called when a download task finishes downloading the file to a temporary location.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) { }
    
    /// Called periodically to report download progress.
    ///
    /// Forwards the progress update to the corresponding task, if found.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        Task {
            let task = await networkTask(for: downloadTask)
            await task?._session(
                didWriteData: bytesWritten,
                totalBytesWritten: totalBytesWritten,
                totalBytesExpectedToWrite: totalBytesExpectedToWrite
            )
        }
    }
    
    /// Called when a download task is resumed from previous download data.
    ///
    /// Forwards the progress update to the corresponding task, if found.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) {
        Task {
            let task = await networkTask(for: downloadTask)
            await task?._session(
                didResumeAtOffset: fileOffset,
                expectedTotalBytes: expectedTotalBytes
            )
        }
    }
}
