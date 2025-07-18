//
//  DownloadTask.swift
//  Networking
//
//  Created by Joe Maghzal on 2/19/25.
//

import Foundation
import NetworkingCore
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
    /// The type used to handle & track the progress of the request.
    private let progressTracker = ProgressTracker()
    
    /// A stream that emits progress updates throughout the download lifecycle.
    ///
    /// The stream completes automatically when ``finish()`` is called.
    public var progressStream: AsyncStream<Double> {
        get async {
            return await progressTracker.progressStream
        }
    }
    
    /// The current progress value.
    public var progress: Double{
        get async {
            return await progressTracker.progress
        }
    }
    
    /// Executes the download task.
    ///
    /// This method starts the download using the session’s ``download(for:)``
    /// method and tracks the progress.
    ///
    /// - Parameters:
    ///   - urlRequest: The request to be executed.
    ///   - session: The session managing the download.
    ///
    /// - Returns: A tuple containing the downloaded ``URL`` and ``URLResponse``.
    @_spi(Internal) open override func _execute(
        _ urlRequest: borrowing URLRequest,
        session: Session
    ) async throws(NetworkingError) -> DownloadResponse {
        await progressTracker.setProgress(0)
        do {
            return try await session.session.download(
                for: urlRequest,
                delegate: session.delegate
            )
        }catch let error as URLError {
            throw .client(.urlError(error))
        }catch {
            throw .custom(error)
        }
    }
    
    /// Called when the task finishes, either successfully or with an error.
    ///
    /// This method finishes the ``progressStream`` and resets the continuation.
    ///
    /// - Parameters:
    ///   - error: An optional error if the task failed.
    @_spi(Internal) open override func _finished(with error: NetworkingError?) async {
        await super._finished(with: error)
        await progressTracker.finish()
    }
    
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    @_spi(Internal) public func _session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async {
        await progressTracker.setProgress(
            Double(totalBytesWritten),
            total: Double(totalBytesExpectedToWrite)
        )
    }
    
    /// Called when a download task is resumed from previous download data.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    @_spi(Internal) public func _session(
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) async {
        await progressTracker.setProgress(
            Double(fileOffset),
            total: Double(expectedTotalBytes)
        )
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
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, macCatalyst 16.0, *)
    public func cancelByProducingResumeData() async -> Data? {
        let downloadTask = await sessionTask as? URLSessionDownloadTask
        return await downloadTask?.cancelByProducingResumeData()
    }
}

/// An actor that tracks and emits download progress updates.
///
/// `ProgressTracker` provides a `progressStream` to emit values
/// representing the fraction of the download completed. It supports both direct
/// and computed progress updates, and safely finishes the stream when done.
///
/// Use this in coordination with download tasks to drive progress UIs.
///
/// - Important: This type is internal and intended for use within the networking framework only.
internal actor ProgressTracker {
// MARK: - Properties
    /// The stream continuation for emitting progress values.
    private var continuation: AsyncStream<Double>.Continuation? {
        didSet {
            continuation?.yield(progress)
        }
    }
    
    /// A stream that emits progress updates throughout the download lifecycle.
    ///
    /// The stream completes automatically when ``finish()`` is called.
    internal private(set) lazy var progressStream: AsyncStream<Double> = {
        return AsyncStream(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            self.continuation = continuation
        }
    }()
    
    /// The current progress value.
    ///
    /// Updating this property emits the new value to the progress stream.
    internal private(set) var progress = Double.zero {
        didSet {
            continuation?.yield(progress)
        }
    }
    
// MARK: - Functions
    /// Sets the progress to the given normalized value.
    ///
    /// If the value is negative, it is clamped to its absolute value.
    ///
    /// - Parameter progress: the progress value.
    internal func setProgress(_ progress: Double) {
        guard self.progress != progress else {return}
        self.progress = abs(progress)
    }
    
    /// Calculates and sets the progress based on completed and total bytes.
    ///
    /// - Parameters:
    ///   - offset: The number of bytes downloaded.
    ///   - total: The total number of bytes expected.
    internal func setProgress(_ offset: Double, total: Double) {
        guard total > 0 else {
            setProgress(0)
            return
        }
        setProgress(offset / total)
    }
    
    /// Completes the progress stream and clears the continuation.
    ///
    /// Call this when the download has finished or been cancelled.
    internal func finish() {
        continuation?.finish()
        continuation = nil
    }
}
