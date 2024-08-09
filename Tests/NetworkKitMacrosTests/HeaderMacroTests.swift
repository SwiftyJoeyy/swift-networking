//
//  HeaderMacroTests.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class HeaderMacroTests: XCTestCase {
//MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Header": HeaderMacro.self
    ]
    
//MARK: - Expansion Tests
    func testHeaderMacroWithInitializer() {
        assertMacroExpansion(
            """
            @Header("Content-Language") var language: String
            """,
            expandedSource: """
            var language: String
            
            private var __language: RequestModifier {
                return Header("Content-Language", value: language)
            }
            """,
            macros: testMacros
        )
    }
    func testHeaderMacroWithoutInitializer() {
        assertMacroExpansion(
            """
            @Header("Content-Language") var language = "en"
            """,
            expandedSource: """
            var language = "en"
            
            private var __language: RequestModifier {
                return Header("Content-Language", value: language)
            }
            """,
            macros: testMacros
        )
    }
}
#endif

//@HeadersCollection
//struct MyHeaders {
//    let lassa: String
//    var headers: [String: String] {
//        "lassa": lassa
//    }
//}
