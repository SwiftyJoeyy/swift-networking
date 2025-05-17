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
import NetworkingCoreMacros

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
            @Header var name = "hi"
            @Parameter var name = "hi"
            """,
            expandedSource: """
            var name = "hi"
            var name = "hi"
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithValueWithKey() {
        assertMacroExpansion(
            """
            @Header("Hi") var name = "hi"
            @Parameter("Hi") var name = "hi"
            """,
            expandedSource: """
            var name = "hi"
            var name = "hi"
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithoutValueWithoutKey() {
        assertMacroExpansion(
            """
            @Header var name: String
            @Parameter var name: String
            """,
            expandedSource: """
            var name: String
            var name: String
            """,
            macros: testMacros
        )
    }
    
    func testExpansionWithoutValueWithKey() {
        assertMacroExpansion(
            """
            @Header("Hi") var name: String
            @Parameter("Hi") var name: String
            """,
            expandedSource: """
            var name: String
            var name: String
            """,
            macros: testMacros
        )
    }
}
#endif
