//
//  ClientInitMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/9/25.
//

import SwiftSyntaxMacros
import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingClientMacros)
@testable import NetworkingClientMacros

final class ClientInitMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
        "ClientInit": ClientInitMacro.self
    ]
    
// MARK: - Expansion Tests
    func testClientInitMacroExpansion() {
        assertMacroExpansion(
            """
            @ClientInit init() { 
            }
            """,
            expandedSource: """
            init() {
                configure()
            }
            """,
            macros: testMacros
        )
    }
    
    func testClientInitMacroWithConfigureExpansion() {
        assertMacroExpansion(
            """
            @ClientInit init() { 
                configure()
            }
            """,
            expandedSource: """
            init() {
                configure()
            }
            """,
            macros: testMacros
        )
    }
    
    func testClientInitMacroWithParametersExpansion() {
        assertMacroExpansion(
            """
            @ClientInit init(test: Int) { 
                self.test = test
            }
            """,
            expandedSource: """
            init(test: Int) {
                self.test = test
                configure()
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Access Level Tests
    func testClientInitMacroWithAccessLevel() {
        for level in AccessLevel.allCases {
            assertMacroExpansion(
            """
            @ClientInit \(level) init() { 
            }
            """,
            expandedSource: """
            \(level) init() {
                configure()
            }
            """,
            macros: testMacros
            )
        }
    }
}
#endif
