//
//  ClientMacroTests.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class ClientMacroTests: XCTestCase {
//MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Client": ClientMacro.self
    ]
    
//MARK: - Expansion Tests
    func testClientMacro() {
        assertMacroExpansion(
            """
            @Client
            struct NetworkClient {
                var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
            }
            """,
            expandedSource: """
            struct NetworkClient {
                @ClientCommandBuilder
                var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
            
                var aggregatedCommand: ClientCommand!
            
                init() {
                    self.aggregatedCommand = command
                }
            }
            
            extension NetworkClient: NetworkingClient {
            }
            """,
            macros: testMacros
        )
    }
    func testClientMacroAddsAttributeToOnlyCommandVariable() {
        assertMacroExpansion(
            """
            @Client
            struct NetworkClient {
                var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
                var test = ""
            }
            """,
            expandedSource: """
            struct NetworkClient {
                @ClientCommandBuilder
                var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
                var test = ""
            
                var aggregatedCommand: ClientCommand!
            
                init() {
                    self.aggregatedCommand = command
                }
            }
            
            extension NetworkClient: NetworkingClient {
            }
            """,
            macros: testMacros
        )
    }
    
//MARK: - Access Levels Tests
    func testClientMacroWithAccessLevel() {
        let levels = AccessLevel.allCases
        for level in levels {
            assertMacroExpansion(
            """
            @Client
            \(level.name) struct NetworkClient {
                \(level.name) var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
            }
            """,
            expandedSource: """
            \(level.name) struct NetworkClient {
                @ClientCommandBuilder
                \(level.name) var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
            
                \(level.name) var aggregatedCommand: ClientCommand!
            
                \(level.name) init() {
                    self.aggregatedCommand = command
                }
            }
            
            extension NetworkClient: NetworkingClient {
            }
            """,
            macros: testMacros
            )
        }
    }
    func testClientMacroAddsAttributeToOnlyCommandVariableWithAccessLevel() {
        let levels = AccessLevel.allCases
        for level in levels {
            assertMacroExpansion(
            """
            @Client
            \(level.name) struct NetworkClient {
                \(level.name) var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
                var test = ""
            }
            """,
            expandedSource: """
            \(level.name) struct NetworkClient {
                @ClientCommandBuilder
                \(level.name) var command: ClientCommand {
                    RequestCommand()
                    DefaultRetryingCommand()
                }
                var test = ""
            
                \(level.name) var aggregatedCommand: ClientCommand!
            
                \(level.name) init() {
                    self.aggregatedCommand = command
                }
            }
            
            extension NetworkClient: NetworkingClient {
            }
            """,
            macros: testMacros
            )
        }
    }

//MARK: - Validation Tests
    func testClientMacroFailsWithMissingDeclarationErrorWhenCommandPropertyIsMissing() {
        let expectedDiagnostics = [
            // The property is missing a 'command' property declaration.
            DiagnosticSpec(message: ClientMacroError.missingCommandDeclaration.message, line: 1, column: 1)
        ]
        
        assertMacroExpansion(
            """
            @Client
            struct NetworkClient {
            }
            """,
            expandedSource: """
            struct NetworkClient {
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif
