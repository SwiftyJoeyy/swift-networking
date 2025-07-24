//
//  ConfigurationKeyMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingCoreMacros)
@testable import NetworkingCoreMacros

final class ConfigurationKeyMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
        "Config": ConfigurationKeyMacro.self
    ]
    
// MARK: - Expansion Tests
    func testConfigurationKeyMacro() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder = JSONDecoder()
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue = JSONDecoder()
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroWithType() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: JSONDecoder = JSONDecoder()
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: JSONDecoder {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue: JSONDecoder = JSONDecoder()
                }
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Optional Type Tests
    func testConfigurationKeyMacroWithOptionalValueWithInitializer() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: JSONDecoder? = nil
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: JSONDecoder? {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue: JSONDecoder? = nil
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroWithOptionalValueWithoutInitializer() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: JSONDecoder?
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: JSONDecoder? {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue: JSONDecoder? = nil
                }
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Force Unwrapp Tests
    func testConfigurationKeyMacroWithForceUnwrapTrue() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: JSONDecoder!
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: JSONDecoder! {
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
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue: JSONDecoder? = nil
                }
            }
            """,
            macros: testMacros
        )
    }
    func testConfigurationKeyMacroWithForceUnwrapTrueAndExistential() {
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: (any Decoder)!
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: (any Decoder)! {
                    get {
                        let value = self[ConfigurationKey_decoder.self]
                        precondition(
                            value != nil,
                            "Missing configuration of type: '(any Decoder)'. Make sure you're setting a value for the key 'decoder' before using it."
                        )
                        return value!
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue: (any Decoder)? = nil
                }
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Validation Tests
    func testConfigurationKeyMacroFailsWhenPropertyIsNotInConfigurationValuesExtension() {
        // Invalid declaration, the macro requires the property to be
        // in an extension of ConfigurationValues.
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroDiagnostic.invalidDeclarationContext.message,
            line: 2,
            column: 5
        )
        
        assertMacroExpansion(
            """
            extension String {
                @Config var decoder = JSONDecoder()
            }
            """,
            expandedSource: """
            extension String {
                var decoder {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWhenMacroIsAppliedToLetProperty() {
        // Invalid property type, the macro requires var instead of let.
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroDiagnostic.invalidPropertyType.message,
            line: 2,
            column: 5,
            fixIts: [
                FixItSpec(message: "Replace 'let' with 'var'")
            ]
        )
        
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config let decoder = JSONDecoder()
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                let decoder = JSONDecoder()
            
                fileprivate struct ConfigurationKey_decoder: NetworkingCore.ConfigurationKey {
                    fileprivate static let defaultValue = JSONDecoder()
                }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWhenMacroIsAppliedToFunction() {
        // Invalid type, the macro can only be applied to vars not funcs.
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroDiagnostic.invalidPropertyType.message,
            line: 2,
            column: 5
        )
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config func decoder() { }
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                func decoder() { }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
    
    func testConfigurationKeyMacroFailsWithMissingInitializerWhenPropertyHasOnlyAName() {
        // The property is missing an initializer
        let diagnostic = DiagnosticSpec(
            message: ConfigurationKeyMacroDiagnostic.missingInitializer.message,
            line: 2,
            column: 5
        )
        
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
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
            message: ConfigurationKeyMacroDiagnostic.missingInitializer.message,
            line: 2,
            column: 5
        )
        
        assertMacroExpansion(
            """
            extension ConfigurationValues {
                @Config var decoder: JSONDecoder
            }
            """,
            expandedSource: """
            extension ConfigurationValues {
                var decoder: JSONDecoder {
                    get {
                        return self[ConfigurationKey_decoder.self]
                    }
                    set {
                        self[ConfigurationKey_decoder.self] = newValue
                    }
                }
            }
            """,
            diagnostics: [diagnostic],
            macros: testMacros
        )
    }
}
#endif
