//
//  NetworkTaskState.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

internal actor NetworkTaskState<T: Sendable> {
// MARK: - Properties
    internal var retryCount = 0
    internal var configurations: NetworkConfigurations
    internal var currentTask: Task<T, any Error>?
    internal var taskName: String?
    
// MARK: - Initializer
    internal init(configurations: NetworkConfigurations) {
        self.configurations = configurations
    }
    
// MARK: - Functions
    internal func incrementRetryCount() {
        retryCount += 1
    }
    internal func activeTask(
        _ perform: @Sendable @escaping () async throws -> T
    ) -> Task<T, any Error> {
        guard currentTask == nil else {
            return currentTask!
        }
        currentTask = Task {
            try await perform()
        }
        return currentTask!
    }
    internal func setTaskName(_ taskName: String?) {
        self.taskName = taskName
    }
    internal func set<Value>(_ value: Value, to keyPath: WritableKeyPath<NetworkConfigurations, Value>) {
        configurations[keyPath: keyPath] = value
    }
}
