//
//  NetworkTasksStorage.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

public protocol TasksStorage: Actor {
    func task(for request: URLRequest) -> (any NetworkingTask)?
    func add(_ task: any NetworkingTask)
    func remove(_ request: URLRequest)
    func cancelAll() async
}

public actor NetworkTasksStorage {
    private var tasks = [URLRequest: any NetworkingTask]()
    
    public init() { }
}

// MARK: - TasksStorage
extension NetworkTasksStorage: TasksStorage {
    public func task(for request: URLRequest) -> (any NetworkingTask)? {
        return tasks[request]
    }
    public func add(_ task: any NetworkingTask) {
        tasks[task.request] = task
    }
    public func remove(_ request: URLRequest) {
        tasks.removeValue(forKey: request)
    }
    public func cancelAll() async {
        for task in tasks {
            await task.value.cancel()
        }
        tasks.removeAll()
    }
}
