//
//  DownloadTask.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/19/25.
//

import Foundation

public typealias DownloadResponse = (url: URL, response: URLResponse)

open class DownloadTask: NetworkTask<DownloadResponse>, @unchecked Sendable, URLSessionDownloadDelegate {
    private var continuation: AsyncStream<Double>.Continuation?
    public private(set) var progressStream: AsyncStream<Double>!
    public private(set) var progress = Double.zero {
        didSet {
            continuation?.yield(progress)
        }
    }
    
    public override init(
        id: String,
        request: consuming URLRequest,
        session: URLSession,
        configurations: NetworkConfigurations
    ) {
        super.init(
            id: id,
            request: request,
            session: session,
            configurations: configurations
        )
        progressStream = AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }
    
    open override func task(
        for request: borrowing URLRequest,
        session: URLSession
    ) async throws -> DownloadResponse {
        progress = 0
        let response = try await session.download(for: request, delegate: self)
        try Task.checkCancellation()
        if let status = response.1.status {
            let validator = await configurations.handlers.statusValidator
            try await validator.validate(self, status: status)
        }
        return response
    }
    open override func finished(
        with error: (any Error)?,
        configurations: NetworkConfigurations
    ) async {
        continuation?.finish()
    }
    open func response() async throws -> DownloadResponse {
        return try await activeTask().value
    }
    
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) { }
}
