//
//  ConfigurationsPropertyWrapperTests.swift
//  Networking
//
//  Created by Joe Maghzal on 22/07/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.configurations))
struct ConfigurationsPropertyWrapperTests {
    @Test func acceptMethodUpdatesConfigurations() {
        let expectedValue = UUID().uuidString
        var configurations = ConfigurationValues()
        configurations.requestID = expectedValue
        
        let configs = Configurations()
        
        #expect(configs.wrappedValue.requestID == nil)
        
        configs._accept(configurations)
        
        #expect(configs.wrappedValue.requestID == expectedValue)
    }
    
    @Test func setValueUpdatesSingleKeyConfiguration() {
        let expectedValue = UUID().uuidString
        
        let configs = Configurations()
        
        #expect(configs.wrappedValue.requestID == nil)
        
        configs.setValue(expectedValue, for: \.requestID)
        
        #expect(configs.wrappedValue.requestID == expectedValue)
    }
}
