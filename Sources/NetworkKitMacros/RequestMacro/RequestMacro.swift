//
//  RequestMacro.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

package enum RequestMacro {
    private static let requestRequirement = "request"
}

//MARK: - MemberMacro
extension RequestMacro: MemberMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try withErroHandling(context: context, node: node, onFailure: []) {
            var hasRequestRequirement = false
            let requestModifiers = declaration.memberBlock.members
                .compactMap { member -> String? in
                    guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self),
                          let propertyName = variableDeclaration.name?.text
                    else {
                        return nil
                    }
                    hasRequestRequirement = propertyName == requestRequirement
                    
                    let validAttribute = variableDeclaration.attributes
                        .contains { attribute in
                            let name = attribute.name?.text
                            return name.flatMap({RequestAttributeType(rawValue: $0)}) != nil
                        }
                    return validAttribute ? "__\(propertyName)": nil
                }
            
            guard hasRequestRequirement else {
                throw RequestMacroError.missingRequestDeclaration
            }
            
            let accessLevel = declaration.modifiers.accessLevel?.modifier ?? ""
            return [
             """
            \(accessLevel)var modifiers: [RequestModifier] {
                get {
                    return [
                        \(raw: requestModifiers.joined(separator: ",\n"))
                    ]
                }
                set { }
            }
            """
            ]
        }
    }
}

//MARK: - ExtensionMacro
extension RequestMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let hasRequestRequirement = declaration.memberBlock.members
            .contains { member in
                let variableDeclaration = member.decl.as(VariableDeclSyntax.self)
                let propertyName = variableDeclaration?.name?.text
                return propertyName == requestRequirement
            }
        guard hasRequestRequirement else {
            return []
        }
        
        let protocolExtension: DeclSyntax =
            """
            extension \(type.trimmed): Request { }
            """
        guard let declaration = protocolExtension.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [declaration]
    }
}
