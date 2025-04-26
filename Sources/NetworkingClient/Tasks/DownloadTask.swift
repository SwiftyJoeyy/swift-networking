//
//  DownloadTask.swift
//  Networking
//
//  Created by Joe Maghzal on 2/19/25.
//

import Foundation

// TODO: - Add support for resumable downloads.

public typealias DownloadResponse = (url: URL, response: URLResponse)

/// Task that handles the download of a file from a given ``URLRequest``,
/// tracking the progress of the download.
///
/// ``DownloadTask`` inherits from ``NetworkTask``, which is
/// responsible for managing the network request, while this class adds
/// download progress tracking functionality and handles download-related
/// logic.
open class DownloadTask: NetworkTask<URL>, @unchecked Sendable {
    /// The continuation used for yielding progress updates.
    private var continuation: AsyncStream<Double>.Continuation?
    
    /// Stream that emits progress updates during the download.
    public private(set) lazy var progressStream: AsyncStream<Double> = {
        return AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }()
    
    /// The current progress of the download.
    public private(set) var progress = Double.zero {
        didSet {
            continuation?.yield(progress)
        }
    }
    
    /// Executes the download task.
    ///
    /// This method starts the download using the session’s ``download(for:)``
    /// method and tracks the progress. It also validates the response status
    /// before returning the downloaded content.
    ///
    /// - Parameters:
    ///   - request: The request to be executed.
    ///   - session: The session managing the download.
    ///
    /// - Returns: A tuple containing the downloaded ``URL`` and ``URLResponse``.
    open override func _execute(
        _ request: borrowing URLRequest,
        session: Session
    ) async throws -> DownloadResponse {
        progress = 0
        return try await session.session.download(
            for: request,
            delegate: session.delegate
        )
    }
    
    /// Called when the task finishes, either successfully or with an error.
    ///
    /// This method finishes the ``progressStream`` and resets the continuation.
    ///
    /// - Parameters:
    ///   - error: An optional error if the task failed.
    ///   - configurations: The configuration values for the task.
    open override func _finished(with error: (any Error)?) async {
        await super._finished(with: error)
        continuation?.finish()
        continuation = nil
    }
    
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    public func _session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async {
        guard totalBytesExpectedToWrite > 0 else {
            progress = 0
            return
        }
        progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }
    
    /// Called when a download task is resumed from previous download data.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    public func _session(
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) async {
        guard expectedTotalBytes > 0 else {
            progress = 0
            return
        }
        progress = Double(fileOffset) / Double(expectedTotalBytes)
    }
}

extension DownloadTask {
    /// Cancels the current download task and produces resume data,
    /// which can be used to resume the task later.
    ///
    /// This method cancels the current task by producing resume data.
    /// The produced resume data can be used to resume the task from where it left off.
    ///
    /// - Returns: The resume data.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    public func cancelByProducingResumeData() async -> Data? {
        let downloadTask = await _sessionTask as? URLSessionDownloadTask
        return await downloadTask?.cancelByProducingResumeData()
    }
}
