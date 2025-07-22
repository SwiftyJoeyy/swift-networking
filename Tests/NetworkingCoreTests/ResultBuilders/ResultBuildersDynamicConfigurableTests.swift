//
//  ResultBuildersDynamicConfigurableTests.swift
//  Networking
//
//  Created by Joe Maghzal on 22/07/2025.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.resultBuilders))
struct ResultBuildersDynamicConfigurableTests {
    @Test func optionalModifierConfiguredWhenCallingAccept() {
        let configurable = MockConfigurable()
        let mod = _OptionalModifier(storage: configurable)
        
        mod._accept(ConfigurationValues())
        
        #expect(configurable.configured)
    }
    
    @Test func conditionalModifierConfiguredWhenCallingAccept() {
        do {
            let configurable = MockConfigurable()
            let mod = _ConditionalModifier<MockConfigurable, MockConfigurable>(storage: .falseContent(configurable))
            
            mod._accept(ConfigurationValues())
            
            #expect(configurable.configured)
        }
        do {
            let configurable = MockConfigurable()
            let mod = _ConditionalModifier<MockConfigurable, MockConfigurable>(storage: .trueContent(configurable))
            
            mod._accept(ConfigurationValues())
            
            #expect(configurable.configured)
        }
    }
    
    @Test func tupleModifierConfiguredWhenCallingAccept() {
        let configurables = (
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable(),
            MockConfigurable()
        )
        let mod = _TupleModifier(value: configurables)
        
        mod._accept(ConfigurationValues())
        
        #expect(configurables.0.configured)
        #expect(configurables.1.configured)
        #expect(configurables.2.configured)
        #expect(configurables.3.configured)
        #expect(configurables.4.configured)
        #expect(configurables.5.configured)
        #expect(configurables.6.configured)
        #expect(configurables.7.configured)
        #expect(configurables.8.configured)
        #expect(configurables.9.configured)
    }
}

extension ResultBuildersDynamicConfigurableTests {
    class MockConfigurable: _DynamicConfigurable {
        var configured = false
        func _accept(_ values: ConfigurationValues) {
            configured.toggle()
        }
    }
}
