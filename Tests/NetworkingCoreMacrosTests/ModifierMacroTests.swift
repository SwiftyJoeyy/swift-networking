//
//  ModifierMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 05/04/2025.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingCoreMacros)
@testable import NetworkingCoreMacros

final class ModifierMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
        "Header": HeaderMacro.self,
        "Parameter": ParameterMacro.self,
    ]
    
// MARK: - Expansion Tests
    func testExpansionWithValueWithoutKey() {
        assertMacroExpansion(
            """
            @Request struct TestRequest {
                @Header var name = "hi"
                @Parameter var name = "hi"
            }
            """,
            expandedSource: """
            @Request struct TestRequest {
                var name = "hi"
                var name = "hi"
            }
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithValueWithKey() {
        assertMacroExpansion(
            """
            @Request struct TestRequest {
                @Header("Hi") var name = "hi"
                @Parameter("Hi") var name = "hi"
            }
            """,
            expandedSource: """
            @Request struct TestRequest {
                var name = "hi"
                var name = "hi"
            }
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithoutValueWithoutKey() {
        assertMacroExpansion(
            """
            @Request struct TestRequest {
                @Header var name: String
                @Parameter var name: String
            }
            """,
            expandedSource: """
            @Request struct TestRequest {
                var name: String
                var name: String
            }
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithoutValueWithKey() {
        assertMacroExpansion(
            """
            @Request struct TestRequest {
                @Header("Hi") var name: String
                @Parameter("Hi") var name: String
            }
            """,
            expandedSource: """
            @Request struct TestRequest {
                var name: String
                var name: String
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Validation Tests
    func testModifierMacroFailsWhenAttachedToPropertiesOutsideAType() {
        let headerDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Header").message,
            line: 1,
            column: 1
        )
        let parameterDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Parameter").message,
            line: 2,
            column: 1
        )
        
        assertMacroExpansion(
            """
            @Header("Hi") var name: String
            @Parameter("Hi") var name: String
            """,
            expandedSource: """
            var name: String
            var name: String
            """,
            diagnostics: [headerDiag, parameterDiag],
            macros: testMacros
        )
    }
    
    func testModifierMacroFailsWhenAttachedToPropertiesInATypeWithoutTheRequestMacro() {
        let headerDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Header").message,
            line: 2,
            column: 5
        )
        let parameterDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Parameter").message,
            line: 3,
            column: 5
        )
        
        assertMacroExpansion(
            """
            struct TestRequest {
                @Header("Hi") var name: String
                @Parameter("Hi") var name: String
            }
            """,
            expandedSource: """
            struct TestRequest {
                var name: String
                var name: String
            }
            """,
            diagnostics: [headerDiag, parameterDiag],
            macros: testMacros
        )
    }
    
    func testModifierMacroFailsWhenMacroIsAppliedToFunction() {
        let headerDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Header").message,
            line: 2,
            column: 5
        )
        let parameterDiag = DiagnosticSpec(
            message: ModifierMacroDiagnostic(macroName: "Parameter").message,
            line: 3,
            column: 5
        )
        
        assertMacroExpansion(
            """
            @Request struct TestRequest {
                @Header func test() { }
                @Parameter func test2() { }
            }
            """,
            expandedSource: """
            @Request struct TestRequest {
                func test() { }
                func test2() { }
            }
            """,
            diagnostics: [headerDiag, parameterDiag],
            macros: testMacros
        )
    }
}
#endif
