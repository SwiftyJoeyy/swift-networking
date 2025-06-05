//
//  MockTasksStorage.swift
//  Networking
//
//  Created by Joe Maghzal on 17/04/2025.
//

import Foundation
@testable import NetworkingClient

actor MockTasksStorage: TasksStorage {
    var cancelled = false
    var tasks = [URLRequest: any NetworkingTask]()
    
    init() { }
    func task(for request: URLRequest) -> (any NetworkingTask)? {
        return tasks[request]
    }
    func add(_ task: some NetworkingTask, for request: URLRequest) {
        tasks[request] = task
    }
    func remove(_ request: borrowing URLRequest) {
        tasks.removeValue(forKey: request)
    }
    func cancelAll() async {
        cancelled = true
    }
}
