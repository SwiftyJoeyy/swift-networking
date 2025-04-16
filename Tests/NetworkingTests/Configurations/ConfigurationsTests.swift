//
//  ConfigurationsTests.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import Testing
@testable import Networking

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
}

extension Tag {
    @Tag internal static var configurations: Self
}
