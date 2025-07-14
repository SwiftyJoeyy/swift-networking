//
//  Session.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation
import NetworkingCore

/// Session responsible for creating and managing network tasks with concurrency support.
///
/// ``Session`` supports defining custom configurations, managing request tasks,
/// and injecting custom delegates and storage mechanisms.
///
/// The ``Session`` conforms to ``Configurable``, allowing fluent-style configuration using key paths.
public actor Session {
// MARK: - Properties
    /// The session delegate responsible for handling ``URLSession`` delegate methods.
    internal let delegate: SessionDelegate
    
    /// The underlying ``URLSession`` used to perform network tasks.
    internal let session: URLSession
    
    /// Stores configuration values such as task storage and custom behaviors.
    @preconcurrency nonisolated(unsafe)
    public private(set) var configurations: ConfigurationValues
    // TODO: - We should avoid using nonisolated here.
    
// MARK: - Initializer
    /// Creates a new ``Session`` with an optional delegate, session configuration,
    /// delegate queue, and task storage.
    ///
    /// - Parameters:
    ///   - sessionDelegate: The delegate for handling session callbacks.
    ///   - configuration: The ``URLSessionConfiguration`` to be used.
    ///   - delegateQueue: The queue on which delegate callbacks are delivered.
    ///   - tasksStorage: Storage mechanism for managing network tasks.
    public init(
        sessionDelegate: SessionDelegate = SessionDelegate(),
        configuration: URLSessionConfiguration = .default,
        delegateQueue queue: OperationQueue? = nil,
        tasksStorage: some TasksStorage = NetworkTasksStorage()
    ) {
        self.delegate = sessionDelegate
        configurations = ConfigurationValues()
        configurations.tasks = tasksStorage
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: queue
        )
        sessionDelegate.tasks = tasksStorage
    }
    
    // TODO: - We should add suppor for URLSession mocking.
    
    /// Creates a new ``Session`` with an optional delegate, session configuration,
    /// delegate queue, and task storage.
    ///
    /// - Parameters:
    ///   - sessionDelegate: The delegate for handling session callbacks.
    ///   - configuration: The ``URLSessionConfiguration`` to be used.
    ///   - delegateQueue: The queue on which delegate callbacks are delivered.
    ///   - tasksStorage: Storage mechanism for managing network tasks.
    public init(
        sessionDelegate: SessionDelegate = SessionDelegate(),
        delegateQueue queue: OperationQueue? = nil,
        tasksStorage: some TasksStorage = NetworkTasksStorage(),
        configuration: () -> URLSessionConfiguration
    ) {
        self.init(
            sessionDelegate: sessionDelegate,
            configuration: configuration(),
            delegateQueue: queue,
            tasksStorage: tasksStorage
        )
    }
    
// MARK: - Task Functions
    /// Cancels all active network tasks managed by the session.
    public func cancelAll() async {
        await configurations.tasks.cancelAll()
    }
    
    /// Creates a ``DataTask`` from a ``Request``.
    ///
    /// - Parameter request: The request to be performed.
    /// - Returns: A ``DataTask`` configured with the session and request.
    nonisolated public func dataTask(
        _ request: some Request
    ) -> DataTask {
        let task = DataTask(
            request: AnyRequest(request),
            session: self
        )
        task._accept(configurations)
        return task
    }
    
    /// Creates a ``DownloadTask`` from a ``Request``.
    ///
    /// - Parameter request: The request to be performed.
    /// - Returns: A ``DownloadTask`` configured with the session and request.
    nonisolated public func downloadTask(
        _ request: some Request
    ) -> DownloadTask {
        let task = DownloadTask(
            request: AnyRequest(request),
            session: self
        )
        task._accept(configurations)
        return task
    }
}

// MARK: - Configurable
extension Session: Configurable {
    /// Sets a configuration value using a key path.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the configuration property.
    ///   - value: The new value to set.
    @discardableResult nonisolated public func configuration<V>(
        _ keyPath: WritableKeyPath<ConfigurationValues, V>,
        _ value: V
    ) -> Self {
        configurations[keyPath: keyPath] = value
        return self
    }
}
