//
//  ClientMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntaxMacros
import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingClientMacros)
@testable import NetworkingClientMacros

final class ClientMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
        "Client": ClientMacro.self
    ]
    
// MARK: - Expansion Tests
    func testClientMacroExpansion() {
        assertMacroExpansion(
            """
            @Client
            struct TestClient {
                var session: Session {
                    Session()
                }
            }
            """,
            expandedSource: """
            struct TestClient {
                var session: Session {
                    Session()
                }
            
                var _session: Session!
            
                @ClientInit init() {
                }
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            macros: testMacros
        )
    }
    
    func testClientMacroAddClientInitMacroToInit() {
        assertMacroExpansion(
            """
            @Client
            struct TestClient {
                init() { }
                var session: Session {
                    Session()
                }
            }
            """,
            expandedSource: """
            struct TestClient {
                @ClientInit
                init() { }
                var session: Session {
                    Session()
                }
            
                var _session: Session!
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            macros: testMacros
        )
    }
    
    func testClientMacroAddClientInitMacroToInitWithParameters() {
        assertMacroExpansion(
            """
            @Client
            struct TestClient {
                init(test: Int) { 
                    self.test = test
                }
                var session: Session {
                    Session()
                }
            }
            """,
            expandedSource: """
            struct TestClient {
                @ClientInit
                init(test: Int) { 
                    self.test = test
                }
                var session: Session {
                    Session()
                }
            
                var _session: Session!
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Access Level Tests
    func testClientMacroWithAccessLevel() {
        for level in AccessLevel.allCases {
            assertMacroExpansion(
            """
            @Client
            \(level) struct TestClient {
                \(level) var session: Session {
                    Session()
                }
            }
            """,
            expandedSource: """
            \(level) struct TestClient {
                \(level) var session: Session {
                    Session()
                }
            
                \(level) var _session: Session!
            
                @ClientInit
                \(level) init() {
                }
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            macros: testMacros
            )
        }
    }
    
    func testClientMacroWithInitWithAccessLevel() {
        for level in AccessLevel.allCases {
            assertMacroExpansion(
            """
            @Client
            \(level) struct TestClient {
                \(level) init() { }
                \(level) var session: Session {
                    Session()
                }
            }
            """,
            expandedSource: """
            \(level) struct TestClient {
                @ClientInit
                \(level) init() { }
                \(level) var session: Session {
                    Session()
                }
            
                \(level) var _session: Session!
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            macros: testMacros
            )
        }
    }
    
// MARK: - Validations Tests
    func testClientMacroFailsWithMissingSessionDeclaration() {
        let expectedDiagnostics = [
            DiagnosticSpec(
                message: ClientMacroDiagnostic.missingSessionDeclaration.message,
                line: 1,
                column: 1
            )
        ]
        
        assertMacroExpansion(
            """
            @Client
            struct TestClient {
                init() { }
            }
            """,
            expandedSource: """
            struct TestClient {
                @ClientInit
                init() { }
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
    
    func testClientMacroFailsWithUnexpectedSessionDeclaration() {
        let expectedDiagnostics = [
            DiagnosticSpec(
                message: ClientMacroDiagnostic.unexpectedSessionDeclaration.message,
                line: 7,
                column: 5,
                fixIts: [
                    FixItSpec(message: "Remove the '_session' property declaration")
                ]
            )
        ]
        
        assertMacroExpansion(
            """
            @Client
            struct TestClient {
                init() { }
                var session: Session {
                    Session()
                }
                var _session: Session!
            }
            """,
            expandedSource: """
            struct TestClient {
                @ClientInit
                init() { }
                var session: Session {
                    Session()
                }
                var _session: Session!
            }
            
            extension TestClient: NetworkClient {
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif
