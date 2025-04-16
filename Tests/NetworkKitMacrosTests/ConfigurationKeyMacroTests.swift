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
    private let testMacros: [String: any Macro.Type] = [
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
                set {
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
    
    func testConfigurationKeyMacroWithType() {
        assertMacroExpansion(
            """
            @Config var decoder: JSONDecoder = JSONDecoder()
            """,
            expandedSource: """
            var decoder: JSONDecoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue: JSONDecoder = JSONDecoder()
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Optional Type Tests
    func testConfigurationKeyMacroWithOptionalValueWithInitializer() {
        assertMacroExpansion(
            """
            @Config var decoder: JSONDecoder? = nil
            """,
            expandedSource: """
            var decoder: JSONDecoder? {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue: JSONDecoder? = nil
            }
            """,
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroWithOptionalValueWithoutInitializer() {
        assertMacroExpansion(
            """
            @Config var decoder: JSONDecoder?
            """,
            expandedSource: """
            var decoder: JSONDecoder? {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue: JSONDecoder? = nil
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Force Unwrapp Tests
    func testConfigurationKeyMacroWithForceUnwrapTrue() {
        assertMacroExpansion(
            """
            @Config(forceUnwrapped: true) var decoder: JSONDecoder
            """,
            expandedSource: """
            var decoder: JSONDecoder {
                get {
                    let value = self[ConfigurationKey_decoder.self]
                    precondition(
                        value != nil,
                        "Missing configuration of type: 'JSONDecoder'. Make sure you're setting a value for the key 'decoder' before using it."
                    )
                    return value!
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue: (JSONDecoder)? = nil
            }
            """,
            macros: testMacros
        )
    }
    func testConfigurationKeyMacroWithForceUnwrapTrueAndExistential() {
        assertMacroExpansion(
            """
            @Config(forceUnwrapped: true) var decoder: any Decoder
            """,
            expandedSource: """
            var decoder: any Decoder {
                get {
                    let value = self[ConfigurationKey_decoder.self]
                    precondition(
                        value != nil,
                        "Missing configuration of type: 'any Decoder'. Make sure you're setting a value for the key 'decoder' before using it."
                    )
                    return value!
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            
            fileprivate struct ConfigurationKey_decoder: ConfigurationKey {
                fileprivate static let defaultValue: (any Decoder)? = nil
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Validation Tests
    func testConfigurationKeyMacroFailsWithInvalidPropertyType() {
        // Invalid property type, the macro requires var instead of let.
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroError.invalidPropertyType.message,
            line: 1,
            column: 1
        )
        
        assertMacroExpansion(
            """
            @Config let decoder = JSONDecoder()
            """,
            expandedSource: """
            let decoder = JSONDecoder()
            """,
            diagnostics: [diagnostic, diagnostic],
            macros: testMacros
        )
        
        assertMacroExpansion(
            """
            @Config func decoder() { }
            """,
            expandedSource: """
            func decoder() { }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingInitializerWhenPropertyHasOnlyAName() {
        // The property is missing an initializer
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroError.missingInitializer.message,
            line: 1,
            column: 1
        )
        
        assertMacroExpansion(
            """
            @Config var decoder
            """,
            expandedSource: """
            var decoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingInitializerWhenPropertyHasATypeButNoValue() {
        // The property is missing an initializer
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroError.missingInitializer.message,
            line: 1,
            column: 1
        )
        
        assertMacroExpansion(
            """
            @Config var decoder: JSONDecoder
            """,
            expandedSource: """
            var decoder: JSONDecoder {
                get {
                    return self[ConfigurationKey_decoder.self]
                }
                set {
                    self[ConfigurationKey_decoder.self] = newValue
                }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingTypeWithForceUnwrappAttribute() {
        // The property is missing a type
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroError.missingTypeAnnotation.message,
            line: 1,
            column: 1
        )
        
        assertMacroExpansion(
            """
            @Config(forceUnwrapped: true) var decoder
            """,
            expandedSource: """
            var decoder
            """,
            diagnostics: [diagnostic, diagnostic],
            macros: testMacros
        )
    }
}
#endif
