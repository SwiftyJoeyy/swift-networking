//
//  DynamicConfigDeclFactoryTests.swift
//  Networking
//
//  Created by Joe Maghzal on 5/28/25.
//

import Foundation
import SwiftSyntax
import Testing
@testable import MacrosKit
#if canImport(NetworkingCoreMacros)
@testable import NetworkingCoreMacros

struct DynamicConfigDeclFactoryTests {
    @Test(arguments: ["config", "configs"])
    func makeDeclWhenConfigurationsAttributeExistsReturnsFunction(propery: TokenSyntax) throws {
        let decl = try StructDeclSyntax(
            """
            struct TestStruct {
                @Configurations var \(propery)
            }
            """
        )
        
        let funcDecl = try #require(DynamicConfigDeclFactory.make(for: decl))
        
        let expectedDecl = """
        func _accept(_ values: NetworkingCore.ConfigurationValues) {
            _\(propery.text)._accept(values)
        }
        """
        #expect(funcDecl.formatted().description == expectedDecl)
    }
    
    @Test func makeDeclWhenNoConfigurationsAttributeExistsReturnsNil() throws {
        let decl = try StructDeclSyntax(
            """
            struct TestStruct {
                var config: String
            }
            """
        )
        
        let funcDecl = DynamicConfigDeclFactory.make(for: decl)
        #expect(funcDecl == nil)
    }
    
    @Test(arguments: AccessLevel.allCases)
    func makeDeclInheritsAccessModifier(accessLevel: TokenSyntax) throws {
        let level = accessLevel.trimmed
        let decl = try StructDeclSyntax(
            """
            \(level) struct TestStruct {
                @Configurations \(level) var config
            }
            """
        )
        
        let funcDecl = try #require(DynamicConfigDeclFactory.make(for: decl))
        
        let expectedDecl = """
        \(level.text) func _accept(_ values: NetworkingCore.ConfigurationValues) {
            _config._accept(values)
        }
        """
        
        #expect(funcDecl.formatted().description == expectedDecl)
    }
}
#endif
