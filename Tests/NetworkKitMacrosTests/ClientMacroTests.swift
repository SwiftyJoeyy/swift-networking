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

//#if canImport(NetworkKitMacros)
//import NetworkKitMacros
//
//final class ClientMacroTests: XCTestCase {
//// MARK: - Properties
//    private let testMacros: [String: Macro.Type] = [
//        "Client": ClientMacro.self,
//        "ClientInit": ClientInitMacro.self
//    ]
//    
//// MARK: - No Modifiers Tests
//    func testRequestMacroWithoutModifiers() {
//        assertMacroExpansion(
//            """
//            @Client
//            struct TTRClient {
//            var modifiers: [any RequestModifier] {
//            get {
//            return modifiersBox + [
//            ]
//            }
//            }
//                var command: Session {
//                    Session()
//                }
//            }
//            """,
//            expandedSource: """
//            struct TTRClient {
//                var command: Session {
//                    RequestCommand()
//                }
//            
//                var _command: Session!
//            
//                init() {
//                    configure()
//                }
//            }
//            
//            extension TTRClient: NetworkClient {
//            }
//            """,
//            macros: testMacros
//        )
//    }
//}
//#endif
