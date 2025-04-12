//
//  NetworkTasksStorage.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

/// Requirements for defining a storage that safely manages a collection of active networking tasks,
/// mapped by their originating ``URLRequest``.
public protocol TasksStorage: Actor {
    /// Retrieves the task associated with a given request, if it exists.
    ///
    /// - Parameter request: The ``URLRequest`` for which to fetch the task.
    /// - Returns: The corresponding ``NetworkingTask``.
    func task(for request: URLRequest) -> (any NetworkingTask)?
    
    /// Adds a new task to the storage, keyed by its originating request.
    ///
    /// - Parameters:
    ///   - task: The task to store.
    ///   - request: The original request associated with the task.
    func add(_ task: some NetworkingTask, for request: URLRequest)
    
    /// Removes a task associated with a given request from the storage.
    ///
    /// - Parameter request: The request whose task should be removed.
    func remove(_ request: URLRequest)
    
    /// Cancels all currently stored tasks and clears the storage.
    func cancelAll() async
}

/// Storage that safely manages a collection of active networking tasks,
/// mapped by their originating ``URLRequest``.
public actor NetworkTasksStorage {
    /// Mapping that stores tasks associated with a request..
    private var tasks = [URLRequest: any NetworkingTask]()
    
    /// Creates a new ``NetworkTasksStorage``.
    public init() { }
}

// MARK: - TasksStorage
extension NetworkTasksStorage: TasksStorage {
    /// Retrieves the task associated with a given request, if it exists.
    ///
    /// - Parameter request: The ``URLRequest`` for which to fetch the task.
    /// - Returns: The corresponding ``NetworkingTask``.
    public func task(for request: URLRequest) -> (any NetworkingTask)? {
        return tasks[request]
    }
    
    /// Adds a new task to the storage, keyed by its originating request.
    ///
    /// - Parameters:
    ///   - task: The task to store.
    ///   - request: The original request associated with the task.
    public func add(_ task: some NetworkingTask, for request: URLRequest) {
        tasks[request] = task
    }
    
    /// Removes a task associated with a given request from the storage.
    ///
    /// - Parameter request: The request whose task should be removed.
    public func remove(_ request: borrowing URLRequest) {
        tasks.removeValue(forKey: request)
    }
    
    /// Cancels all currently stored tasks and clears the storage.
    public func cancelAll() async {
        for task in tasks {
            await task.value.cancel()
        }
        tasks.removeAll()
    }
}
