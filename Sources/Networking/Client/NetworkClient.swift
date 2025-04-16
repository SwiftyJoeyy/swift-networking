//
//  NetworkClient.swift
//  Networking
//
//  Created by Joe Maghzal on 2/21/25.
//

import Foundation

// TODO: - Add support for background
/// Requirements for defining network clients that handle session management
/// and perform network requests, such as data tasks and download tasks.
/// It provides an abstraction for the session and commands network requests based on that session.
public protocol NetworkClient {
    /// The internal session command that is used to execute network requests.
    var _session: Session! {get set}
    
    /// The command that provides access to the network session.
    var session: Session {get}
}

extension NetworkClient {
    /// Configures the network client.
    /// This function should be called once to initialize the network client with a specific session.
    public mutating func configure() {
        _session = session
    }
    
    /// Cancels all ongoing network tasks in the current session.
    @inlinable @inline(__always) public func cancelAll() async {
        await _session.cancelAll()
    }
    
    /// Creates a ``DataTask`` from a ``Request``.
    ///
    /// - Parameter request: The request to be performed.
    /// - Returns: A ``DataTask`` configured with the session and request.
    @inlinable @inline(__always) public func dataTask(
        _ request: consuming some Request
    ) throws -> DataTask {
        return try _session.dataTask(consume request)
    }
    
    /// Creates a ``DownloadTask`` from a ``Request``.
    ///
    /// - Parameter request: The request to be performed.
    /// - Returns: A ``DownloadTask`` configured with the session and request.
    @inlinable @inline(__always) public func downloadTask(
        _ request: consuming some Request
    ) throws -> DownloadTask {
        return try _session.downloadTask(consume request)
    }
}
