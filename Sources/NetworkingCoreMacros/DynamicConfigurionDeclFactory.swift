//
//  DynamicConfigurionDeclFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 25/05/2025.
//

import SwiftSyntax

internal enum DynamicConfigDeclFactory {
    private static func getConfigsDeclName(
        declaration: some DeclGroupSyntax
    ) -> TokenSyntax? {
        for member in declaration.memberBlock.members {
            guard let decl = member.decl.as(VariableDeclSyntax.self) else {continue}
            
            let hasConfigAttr = decl.attributes.contains { attribute in
                return attribute.name?.trimmed.text == "Configurations"
            }
            
            if hasConfigAttr {
                return decl.name
            }
        }
        return nil
    }
    
    internal static func make(
        for declaration: some DeclGroupSyntax
    ) -> FunctionDeclSyntax? {
        guard let declName = getConfigsDeclName(declaration: declaration) else {
            return nil
        }
        let body: ExprSyntax = """
        _\(declName)._accept(values)
        """
        let type = IdentifierTypeSyntax(name: "ConfigurationValues")
        let modifiers = declaration.modifiers.filter({$0.name.isAccessLevel})
        let funcDecl = FunctionDeclSyntax(
            modifiers: modifiers,
            name: "_accept",
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: [
                        FunctionParameterSyntax(
                            firstName: "_",
                            secondName: "values",
                            type: type
                        )
                    ]
                )
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax(
                    [CodeBlockItemSyntax(item: .expr(body))]
                )
            )
        )
        return funcDecl
    }
}

extension TokenSyntax {
    internal var isAccessLevel: Bool {
        switch tokenKind {
            case .keyword(let keyword):
                return keyword == .public || keyword == .internal || keyword == .fileprivate || keyword == .private || keyword == .fileprivate || keyword == .open || keyword == .package
            default:
                return false
        }
    }
}
