//
//  SessionDelegate.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

open class SessionDelegate: NSObject, @unchecked Sendable {
    public internal(set) var tasks: (any TasksStorage)!
    
    public override init() { }
}

// MARK: - URLSessionDelegate
extension SessionDelegate: URLSessionDelegate {
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
        let handler = await task.configurations.handlers.redirectionHandler
        let behavior = await handler.redirect(
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
        let handler = await task.configurations.handlers.cacheHandler
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
