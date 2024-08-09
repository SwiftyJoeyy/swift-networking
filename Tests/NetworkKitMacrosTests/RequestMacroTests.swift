//
//  RequestMacroTests.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class RequestMacroTests: XCTestCase {
//MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Request": RequestMacro.self
    ]
    
//MARK: - No Modifiers Tests
    func testRequestMacroWithoutModifiers() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var modifiers: [RequestModifier] {
                    get {
                        return [
            
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
//MARK: - Modifiers With Initializer Tests
    func testRequestMacroWithOneModifier() {
        let modifiers = ["Header", "Parameter"]
        for modifier in modifiers {
            assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @\(modifier)("Content-Language") var contentLanguage = "en"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @\(modifier)("Content-Language") var contentLanguage = "en"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var modifiers: [RequestModifier] {
                    get {
                        return [
                            __contentLanguage
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
            )
        }
    }
    func testRequestMacroWithMultipleModifiers() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Header("Content-Language") var contentLanguage = "en"
                @Header("Content-Type") var contentType = "json"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Header("Content-Language") var contentLanguage = "en"
                @Header("Content-Type") var contentType = "json"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var modifiers: [RequestModifier] {
                    get {
                        return [
                            __contentLanguage,
                            __contentType
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
//MARK: - Modifiers Without Initializer Tests
    func testRequestMacroWithOneModifierWithoutInitializer() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var modifiers: [RequestModifier] {
                    get {
                        return [
                            __contentLanguage
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    func testRequestMacroWithMultipleModifiersWithoutInitializers() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                @Header("Content-Type") var contentType: String
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                @Header("Content-Type") var contentType: String
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var modifiers: [RequestModifier] {
                    get {
                        return [
                            __contentLanguage,
                            __contentType
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }

//MARK: - Access Levels Tests
    func testRequestMacroWithAccessLevel() {
        let levels = AccessLevel.allCases
        for level in levels {
            assertMacroExpansion(
            """
            @Request
            \(level.name) struct TestRequest {
                \(level.name) var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            \(level.name) struct TestRequest {
                \(level.name) var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                \(level.name) var modifiers: [RequestModifier] {
                    get {
                        return [
            
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
            )
        }
    }
    func testRequestMacroWithAccessLevelAndModifiers() {
        let levels = AccessLevel.allCases
        for level in levels {
            assertMacroExpansion(
            """
            @Request
            \(level.name) struct TestRequest {
                @Header("Content-Language") \(level.name) var contentLanguage = "en"
                @Parameter("Content-Type") \(level.name) var contentType = "json"
                \(level.name) var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            \(level.name) struct TestRequest {
                @Header("Content-Language") \(level.name) var contentLanguage = "en"
                @Parameter("Content-Type") \(level.name) var contentType = "json"
                \(level.name) var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                \(level.name) var modifiers: [RequestModifier] {
                    get {
                        return [
                            __contentLanguage,
                            __contentType
                        ]
                    }
                    set {
                    }
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
            )
        }
    }
    
//MARK: - Validation Tests
    func testClientMacroFailsWithMissingDeclarationErrorWhenCommandPropertyIsMissing() {
        let expectedDiagnostics = [
            // The property is missing a 'request' property declaration.
            DiagnosticSpec(message: RequestMacroError.missingRequestDeclaration.message, line: 1, column: 1)
        ]
        
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                @Header("Content-Type") var contentType: String
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Header("Content-Language") var contentLanguage: String
                @Header("Content-Type") var contentType: String
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif
