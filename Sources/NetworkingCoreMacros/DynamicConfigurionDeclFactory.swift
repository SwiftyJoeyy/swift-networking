//
//  DynamicConfigurionDeclFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 25/05/2025.
//

import SwiftSyntax
import MacrosKit

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
        return FunctionDeclSyntax(
            modifiers: declaration.modifiers.filter({$0.name.isAccessLevel}),
            name: "_accept",
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: [
                        FunctionParameterSyntax(
                            firstName: "_",
                            secondName: "values",
                            type: IdentifierTypeSyntax(name: "NetworkingCore.ConfigurationValues")
                        )
                    ]
                )
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax(
                    [
                        CodeBlockItemSyntax(
                            item: .expr("_\(declName)._accept(values)")
                        )
                    ]
                )
            )
        )
    }
}

