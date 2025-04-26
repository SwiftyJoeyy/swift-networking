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
    private var tasks = [URLRequest: any NetworkingTask]()
    
    init() { }
    func task(for request: URLRequest) -> (any NetworkingTask)? {
        return nil
    }
    func add(_ task: some NetworkingTask, for request: URLRequest) {
    }
    func remove(_ request: borrowing URLRequest) {
    }
    func cancelAll() async {
        cancelled = true
    }
}
