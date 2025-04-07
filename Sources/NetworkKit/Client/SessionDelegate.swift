//
//  SessionDelegate.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

/// Centralized handler for networking-related delegate callbacks such as
/// redirections, caching, and progress reporting.
///
/// It is marked as `@unchecked Sendable` due to its reference type nature and the fact that
/// it manually coordinates access to `tasks`, which is expected to be used safely in concurrent contexts.
open class SessionDelegate: NSObject, @unchecked Sendable {
    /// Reference to the ``TasksStorage`` that manages active network tasks.
    /// Set internally by the ``Session`` and used to
    /// locate task metadata based on the original request.
    public internal(set) var tasks: (any TasksStorage)!
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
            guard let originalRequest = task.originalRequest,
                  let networkTask = await tasks.task(for: originalRequest)
            else {return}
            await networkTask.set(task)
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
        guard let originalRequest = task.originalRequest,
              let task = await tasks.task(for: originalRequest)
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
        guard let originalRequest = dataTask.originalRequest,
              let task = await tasks.task(for: originalRequest)
        else {
            return proposedResponse
        }
        let handler = await task.configurations.cacheHandler
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
    /// Forwards the progress update to the corresponding task instance, if found.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        Task {
            guard let originalRequest = downloadTask.originalRequest,
                  let task = await tasks.task(for: originalRequest)
            else {return}
            await task.session(
                didWriteData: bytesWritten,
                totalBytesWritten: totalBytesWritten,
                totalBytesExpectedToWrite: totalBytesExpectedToWrite
            )
        }
    }

    // MARK: - TODO: Add support for resumable downloads
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) {
//        Task {
//            guard let originalRequest = downloadTask.originalRequest,
//                  let task = await tasks.task(for: originalRequest)
//            else {return}
//        }
    }
}
