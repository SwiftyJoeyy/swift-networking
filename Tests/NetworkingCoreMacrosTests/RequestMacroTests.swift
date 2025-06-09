//
//  RequestMacroTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/12/25.
//

import SwiftSyntaxMacros
@testable import MacrosKit
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NetworkingCoreMacros)
@testable import NetworkingCoreMacros

final class RequestMacroTests: XCTestCase {
// MARK: - Properties
    private let testMacros: [String: any Macro.Type] = [
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Header("contentLanguage", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Header("contentLanguage", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Header("Content-Language", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Header("contentLanguage", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
            
                @ModifiersBuilder var modifier: some RequestModifier {
                    Header("Content-Language", value: contentLanguage)
                    Header("contentType", value: contentType)
                }
            
                let id = "TestRequest"
            }
            
            extension TestRequest: Request {
            }
            
            extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("contentType", value: contentType)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("contentType", value: contentType)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("content-type", value: contentType)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("content-type", value: contentType)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("content-type", value: contentType)
                Parameter("contentLanguage", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
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
        
            @ModifiersBuilder var modifier: some RequestModifier {
                Parameter("content-type", value: contentType)
                Header("contentLanguage", value: contentLanguage)
            }
        
            let id = "TestRequest"
        }
        
        extension TestRequest: Request {
        }
        
        extension TestRequest: ModifiableRequest {
        }
        """,
        macros: testMacros
        )
    }
    
// MARK: - Configurations Tests
    func testRequestMacroWithConfigurations() {
        assertMacroExpansion(
            """
            @Request
            struct TestRequest {
                @Configurations var configs
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            struct TestRequest {
                @Configurations var configs
                var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                let id = "TestRequest"
            
                func _accept(_ values: ConfigurationValues) {
                    _configs._accept(values)
                }
            }
            
            extension TestRequest: Request {
            }
            """,
            macros: testMacros
        )
    }

// MARK: - Access Levels Tests
    func testRequestMacroWithAccessLevel() {
        let id = "Test"
        for level in AccessLevel.allCases {
            assertMacroExpansion(
            """
            @Request("\(id)")
            \(level) struct TestRequest {
                \(level) var request: some Request {
                    HTTPRequest(path: "path")
                }
            }
            """,
            expandedSource: """
            \(level) struct TestRequest {
                \(level) var request: some Request {
                    HTTPRequest(path: "path")
                }
            
                \(level) let id = "\(id)"
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
            DiagnosticSpec(message: RequestMacroDiagnostic.missingRequestDeclaration.message, line: 1, column: 1)
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
            
            extension TestRequest: Request {
            }
            
            extension TestRequest: ModifiableRequest {
            }
            """,
            diagnostics: expectedDiagnostics,
            macros: testMacros
        )
    }
}
#endif

