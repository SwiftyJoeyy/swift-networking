//
//  RequestConfigurationsMock.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
@testable import Networking

extension ConfigurationValues {
    static let mock: ConfigurationValues = {
        var values = ConfigurationValues()
        values.baseURL = URL(string: "example.com")
        return values
    }()
}

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
