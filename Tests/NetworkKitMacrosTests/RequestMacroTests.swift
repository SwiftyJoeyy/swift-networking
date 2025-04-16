//
//  RequestMacroTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntaxMacros
import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkKitMacros)
import NetworkKitMacros

final class RequestMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: Macro.Type] = [
        "Request": RequestMacro.self
    ]
    
// MARK: - No Modifiers Tests
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
            
                var _modifiers = [any RequestModifier]()
            
                let id = "TestRequest"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
    func testRequestMacroWithUnknownModifierAndFunction() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Test var test = ""
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                func test() { }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Test var test = ""
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                func test() { }
            
                var _modifiers = [any RequestModifier]()
            
                let id = "TestRequest"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - ID Attribute Tests
    func testRequestMacroWithIDAttribute() {
        let id = "Hello"
        assertMacroExpansion(
            """
            @Request("\(id)")
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
            
                var _modifiers = [any RequestModifier]()
            
                let id = "\(id)"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
    func testRequestMacroWithoutIDAttribute() {
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
            
                var _modifiers = [any RequestModifier]()
            
                let id = "TestRequest"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
    func testRequestMacroWithIDAttributeWithExplicitID() {
        let id = "testing"
        assertMacroExpansion(
            """
            @Request("some-id")
            struct TestRequest {
                let id = "\(id)"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                let id = "\(id)"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var _modifiers = [any RequestModifier]()
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
    func testRequestMacroWithoutIDAttributeWithExplicitID() {
        let id = "testing"
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                let id = "\(id)"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                let id = "\(id)"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var _modifiers = [any RequestModifier]()
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Header Tests
    func testRequestMacroWithOneHeaderWithoutCustomName() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Header var contentLanguage = "en"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Header var contentLanguage = "en"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        HeadersGroup(
                            [
                                "contentLanguage": contentLanguage,
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneHeaderWithOptionalValue() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Header var contentLanguage: String?
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Header var contentLanguage: String?
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        HeadersGroup(
                            [
                                "contentLanguage": contentLanguage,
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneHeaderWithCustomName() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Header("Content-Language") var contentLanguage = "en"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Header("Content-Language") var contentLanguage = "en"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        HeadersGroup(
                            [
                                "Content-Language": contentLanguage,
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneHeaderWithoutInitializer() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Header var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Header var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        HeadersGroup(
                            [
                                "contentLanguage": contentLanguage,
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithMultipleHeaders() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Header("Content-Language") var contentLanguage = "en"
                @Header var contentType = "json"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Header("Content-Language") var contentLanguage = "en"
                @Header var contentType = "json"
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                var _modifiers: [any RequestModifier] {
                    get {
                        return _modifiersBox + [
                            HeadersGroup(
                                [
                                    "Content-Language": contentLanguage,
                                    "contentType": contentType,
                                ]
                            ),
                        ]
                    }
                    set {
                        _modifiersBox = newValue
                    }
                }
            
                private var _modifiersBox = [any RequestModifier]()
            
                let id = "TestRequest"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }
    
// MARK: - Parameters Tests
    func testRequestMacroWithOneParameterWithoutCustomName() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter var contentType = "1"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter var contentType = "1"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        ParametersGroup(
                            [
                                URLQueryItem(name: "contentType", value: String(contentType)),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneParameterWithOptionalValue() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter var contentType: String?
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter var contentType: String?
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        ParametersGroup(
                            [
                                contentType.map({
                                        URLQueryItem(name: "contentType", value: String($0))
                                    }),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneParameterWithCustomName() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        ParametersGroup(
                            [
                                URLQueryItem(name: "content-type", value: String(contentType)),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithOneParameterWithoutInitializer() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter("content-type") var contentType: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter("content-type") var contentType: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        ParametersGroup(
                            [
                                URLQueryItem(name: "content-type", value: String(contentType)),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    func testRequestMacroWithMultipleParameters() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            @Parameter var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            @Parameter var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        ParametersGroup(
                            [
                                URLQueryItem(name: "content-type", value: String(contentType)),
                                URLQueryItem(name: "contentLanguage", value: String(contentLanguage)),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }
    
// MARK: - Headers & Parameters Tests
    func testRequestMacroWithParametersAndHeaders() {
        assertMacroExpansion(
        """
        @Request
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            @Header var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        }
        """,
        expandedSource: """
        struct TestRequest {
            @Parameter("content-type") var contentType = "1"
            @Header var contentLanguage: String
            var request: some Request {
                HTTPRequest(path: "path")
            }
        
            var _modifiers: [any RequestModifier] {
                get {
                    return _modifiersBox + [
                        HeadersGroup(
                            [
                                "contentLanguage": contentLanguage,
                            ]
                        ),
                        ParametersGroup(
                            [
                                URLQueryItem(name: "content-type", value: String(contentType)),
                            ]
                        ),
                    ]
                }
                set {
                    _modifiersBox = newValue
                }
            }
        
            private var _modifiersBox = [any RequestModifier]()
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        """,
        macros: testMacros
        )
    }

// MARK: - Access Levels Tests
    func testRequestMacroWithAccessLevel() {
        let levels = AccessLevel.allCases
        let id = "Test"
        for level in levels {
            assertMacroExpansion(
            """
            @Request("\(id)")
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
            
                \(level.name) var _modifiers = [any RequestModifier]()
            
                \(level.name) let id = "\(id)"
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
            )
        }
    }
    
// MARK: - Validation Tests
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

