//
//  ClientMacroTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import SwiftSyntaxMacros
import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class ClientMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Client": ClientMacro.self,
        "ClientInit": ClientInitMacro.self
    ]
    
// MARK: - No Modifiers Tests
    func testRequestMacroWithoutModifiers() {
        assertMacroExpansion(
            """
            @Client
            struct TTRClient {
                var command: RequestCommand {
                    RequestCommand()
                }
            }
            """,
            expandedSource: """
            struct TTRClient {
                var command: RequestCommand {
                    RequestCommand()
                }
            
                var _command: RequestCommand!
            
                init() {
                    configure()
                }
            }
            
            extension TTRClient: NetworkClient {
            }
            """,
            macros: testMacros
        )
    }
}
#endif
