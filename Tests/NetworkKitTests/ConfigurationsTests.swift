//
//  ConfigurationsTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import Testing
@testable import NetworkKit

@Suite(.tags(.configurations))
struct ConfigurationsTests {
    @Test func defaultValueForKey() {
        let configurations = ConfigurationValues()
        let value = configurations[MockKey.self]
        
        #expect(value == MockKey.defaultValue)
    }
    
    @Test func setAndGetValueForKey() {
        var configurations = ConfigurationValues()
        
        let expectedValue = "Custom Value"
        configurations[MockKey.self] = expectedValue
        
        let value = configurations[MockKey.self]
        #expect(value == expectedValue)
    }
    
    @Test func optionalConfigurationKey() {
        var configurations = ConfigurationValues()
        
        #expect(configurations[OptionalMockKey.self] == nil)
        
        let expectedValue = "Custom Value"
        configurations[OptionalMockKey.self] = expectedValue
        
        let value = configurations[OptionalMockKey.self]
        #expect(value == expectedValue)
    }
    
    @Test func settingTasksAndAccessingIt() {
        var configurations = ConfigurationValues()
        let tasks = MockTasksStorage()
        configurations.tasks = tasks
        
        #expect(configurations.tasks === tasks)
    }
}

extension ConfigurationsTests {
    struct MockKey: ConfigurationKey {
        typealias Value = String
        static let defaultValue: String = "Default Value"
    }
    struct OptionalMockKey: ConfigurationKey {
        typealias Value = String?
        static let defaultValue: String? = nil
    }
    
    actor MockTasksStorage: TasksStorage {
        private var tasks = [URLRequest: any NetworkingTask]()
        
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
            for task in tasks {
                await task.value.cancel()
            }
            tasks.removeAll()
        }
    }
}
