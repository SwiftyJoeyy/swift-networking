//
//  RequestModifierMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 5/28/25.
//

import SwiftSyntaxMacros
import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingCoreMacros)
@testable import NetworkingCoreMacros

final class RequestModifierMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
        "RequestModifier": RequestModifierMacro.self
    ]
    
// MARK: - Tests
    func testMacroAddsRequestMacroCoformance() {
        assertMacroExpansion(
            """
            @RequestModifier
            struct TestModifier {
            }
            """,
            expandedSource: """
            struct TestModifier {
            }
            
            extension TestModifier: NetworkingCore.RequestModifier {
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacroAddsAcceptFunctionsWhenConfigurationsAttributeExists() {
        assertMacroExpansion(
            """
            @RequestModifier
            struct TestModifier {
                @Configurations var configs
            }
            """,
            expandedSource: """
            struct TestModifier {
                @Configurations var configs
            
                func _accept(_ values: NetworkingCore.ConfigurationValues) {
                    _configs._accept(values)
                }
            }
            
            extension TestModifier: NetworkingCore.RequestModifier {
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacroAddsAccessLevelsToFunctions() {
        for level in AccessLevel.allCases {
            assertMacroExpansion(
            """
            @RequestModifier
            \(level) struct TestModifier {
                @Configurations var configs
            }
            """,
            expandedSource: """
            \(level) struct TestModifier {
                @Configurations var configs
            
                \(level) func _accept(_ values: NetworkingCore.ConfigurationValues) {
                    _configs._accept(values)
                }
            }
            
            extension TestModifier: NetworkingCore.RequestModifier {
            }
            """,
            macros: testMacros
            )
        }
    }
}
#endif
