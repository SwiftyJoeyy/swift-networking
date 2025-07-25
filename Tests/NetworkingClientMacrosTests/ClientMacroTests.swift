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
            
                var _session: NetworkingClient.Session!
            
                @NetworkingClient.ClientInit init() {
                }
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
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
                @NetworkingClient.ClientInit
                init() { }
                var session: Session {
                    Session()
                }
            
                var _session: NetworkingClient.Session!
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
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
                @NetworkingClient.ClientInit
                init(test: Int) { 
                    self.test = test
                }
                var session: Session {
                    Session()
                }
            
                var _session: NetworkingClient.Session!
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
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
            
                \(level) var _session: NetworkingClient.Session!
            
                @NetworkingClient.ClientInit
                \(level) init() {
                }
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
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
                @NetworkingClient.ClientInit
                \(level) init() { }
                \(level) var session: Session {
                    Session()
                }
            
                \(level) var _session: NetworkingClient.Session!
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
            }
            """,
            macros: testMacros
            )
        }
    }
    
// MARK: - Validations Tests
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
                @NetworkingClient.ClientInit
                init() { }
                var session: Session {
                    Session()
                }
                var _session: Session!
            }
            
            extension TestClient: NetworkingClient.NetworkClient {
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif
