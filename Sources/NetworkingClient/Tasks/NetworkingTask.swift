//
//  NetworkingTask.swift
//  Networking
//
//  Created by Joe Maghzal on 4/10/25.
//

import Foundation
import NetworkingCore

/// Network task that can be scheduled, cancelled, and reported on.
///
/// All conforming types must be ``Sendable`` and must provide async access
/// to key task properties like the request, retry count, and configurations.
public protocol NetworkingTask: Sendable {
    /// A unique identifier for this task.
    var id: String {get}
    
    /// The underlying ``URLRequest`` associated with this task.
    var request: URLRequest {get async}
    
    /// The number of retry attempts made for this task.
    var retryCount: Int {get async}
    
    /// The current task metrics.
    var metrics: URLSessionTaskMetrics? {get async}
    
    /// The current configuration values that influence task behavior.
    var configurations: ConfigurationValues {get}
    
    /// Cancels the task if it's currently running.
    @discardableResult func cancel() async -> Self
    
    /// Resumes or starts the task execution.
    @discardableResult func resume() async -> Self
    
    
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    func _session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async
    
    /// Called when a download task is resumed from previous download data.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    func _session(
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) async
    
    /// Called when a task has finished collecting metrics.
    ///
    /// This is typically called by the ``URLSessionTaskDelegate`` during download.
    func _session(collected metrics: URLSessionTaskMetrics) async
    
    
    /// Suspends the task if it's currently running.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    @discardableResult func suspend() async -> Self
    
    /// Sets the ``URLSessionTask``.
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    func _set(_ task: URLSessionTask) async
}

// MARK: - Default Implementations
extension NetworkingTask {
    /// Reports download progress to the task.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    public func _session(
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) async { }
    
    /// Called when a download task is resumed from previous download data.
    ///
    /// This is typically called by the ``URLSessionDownloadDelegate`` during download.
    public func _session(
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64
    ) async { }
    
    /// Called when a task has finished collecting metrics.
    ///
    /// This is typically called by the ``URLSessionTaskDelegate`` during download.
    func _session(collected metrics: URLSessionTaskMetrics) async { }
}
