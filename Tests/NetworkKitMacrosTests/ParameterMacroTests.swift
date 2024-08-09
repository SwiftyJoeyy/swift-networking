//
//  ParameterMacroTests.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class ParameterMacroTests: XCTestCase {
//MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Parameter": ParameterMacro.self
    ]
    
//MARK: - Expansion Tests
    func testHeaderMacroWithInitializer() {
        assertMacroExpansion(
            """
            @Parameter("Content-Language") var language: String
            """,
            expandedSource: """
            var language: String
            
            private var __language: RequestModifier {
                return Parameter("Content-Language", value: language)
            }
            """,
            macros: testMacros
        )
    }
    func testHeaderMacroWithoutInitializer() {
        assertMacroExpansion(
            """
            @Parameter("Content-Language") var language = "en"
            """,
            expandedSource: """
            var language = "en"
            
            private var __language: RequestModifier {
                return Parameter("Content-Language", value: language)
            }
            """,
            macros: testMacros
        )
    }
}
#endif
