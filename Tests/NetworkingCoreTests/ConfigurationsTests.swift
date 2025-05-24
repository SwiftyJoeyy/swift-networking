//
//  ConfigurationsTests.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.configurations))
struct ConfigurationsTests {
    @Test func urlConfiguration() {
        let url = URL(string: "https://example.com")!
        let configured = TestConfigurable().baseURL(url)
        #expect(configured.configurationValues.baseURL == url)
    }
    
    @Test func urlStringConfiguration() {
        let urlString = "https://string-url.com"
        let configured = TestConfigurable().baseURL(urlString)
        #expect(configured.configurationValues.baseURL == URL(string: urlString))
    }
    
    @Test func encoderConfiguration() {
        let encoder = JSONEncoder()
        let configured = TestConfigurable().encode(with: encoder)
        #expect(configured.configurationValues.encoder === encoder)
    }
    
    @Test func decoderConfiguration() {
        let decoder = JSONDecoder()
        let configured = TestConfigurable().decode(with: decoder)
        #expect(configured.configurationValues.decoder === decoder)
    }
    
    @Test func bufferSizeConfiguration() {
        let size = 3092
        let configured = TestConfigurable().bufferSize(size)
        #expect(configured.configurationValues.bufferSize == size)
    }
    
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
}

// MARK: - Description Tests
extension ConfigurationsTests {
    @Test func descriptionIsEmptyForNoValues() {
        let configurations = ConfigurationValues()
        let result = configurations.description
        
        #expect(result == "ConfigurationValues = []")
    }
    
    @Test func descriptionIncludesAllValues() {
        var configurations = ConfigurationValues()
       
        do {
            let expectedValue = "Custom Value"
            configurations[MockKey.self] = expectedValue
        }
        
        do {
            let expectedValue = "Custom Value2"
            configurations[OptionalMockKey.self] = expectedValue
        }
        
        let result = configurations.description
        
        #expect(result.contains("MockKey : Custom Value"))
        #expect(result.contains("OptionalMockKey : Optional(\"Custom Value2\")"))
    }
}

extension ConfigurationsTests {
    struct TestConfigurable: Configurable {
        var configurationValues = ConfigurationValues()
        
        consuming func configuration<V>(
            _ keyPath: WritableKeyPath<ConfigurationValues, V>,
            _ value: V
        ) -> TestConfigurable {
            configurationValues[keyPath: keyPath] = value
            return self
        }
    }
    
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
