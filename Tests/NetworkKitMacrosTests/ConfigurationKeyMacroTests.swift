//
//  ConfigurationKeyMacroTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class ConfigurationKeyMacroTests: XCTestCase {
    // MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Config": ConfigurationKeyMacro.self
    ]
    
    // MARK: - Expansion Tests
    func testConfigurationKeyMacro() {
        assertMacroExpansion(
            """
            @Config var decoder = JSONDecoder()
            """,
            expandedSource: """
            var decoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set(newValue) {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue = JSONDecoder()
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Validation Tests
    func testConfigurationKeyMacroFailsWithInvalidPropertyTypeWhenPropertyIsLet() {
        // Invalid property type, the macro requires var instead of let.
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroError.invalidPropertyType.message,
            line: 1,
            column: 1
        )
        
        // Expect 2 diagnostics since both the PeerMacro & the AccessorMacro fail & throw the error.
        let expectedDiagnostics = [diagnostic, diagnostic]
        
        assertMacroExpansion(
            """
            @Config let decoder = JSONDecoder()
            """,
            expandedSource: """
            let decoder = JSONDecoder()
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingDefaultValueWhenPropertyHasOnlyAName() {
        // Expect 1 diagnostic since only the PeerMacro fails & throws the error.
        let expectedDiagnostics = [
            // The property is missing a default value
            DiagnosticSpec(
                message: ConfigurationKeyMacroError.missingDefaultValue.message,
                line: 1,
                column: 1
            )
        ]
        
        assertMacroExpansion(
            """
            @Config var decoder
            """,
            expandedSource: """
            var decoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set(newValue) {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingDefaultValueWhenPropertyHasATypeButNoValue() {
        // Expect 1 diagnostic since only the PeerMacro fails & throws the error.
        let expectedDiagnostics = [
            // The property is missing a default value
            DiagnosticSpec(
                message: ConfigurationKeyMacroError.missingDefaultValue.message,
                line: 1,
                column: 1
            )
        ]
        
        assertMacroExpansion(
            """
            @Config var decoder: JSONDecoder
            """,
            expandedSource: """
            var decoder: JSONDecoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set(newValue) {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif
