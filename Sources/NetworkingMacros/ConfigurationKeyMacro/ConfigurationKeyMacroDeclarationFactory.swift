//
//  ConfigurationKeyMacroDeclarationFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 4/16/25.
//

import SwiftSyntax

extension ConfigurationKeyMacro {
    /// Factory for creating declarations for the ``ConfigurationKeyMacro``.
    internal enum DeclarationsFactory { }
}

// MARK: - Functions
extension ConfigurationKeyMacro.DeclarationsFactory {
    private static func makeSetAccessor(
        keyName: TokenSyntax
    ) -> AccessorDeclSyntax {
        return AccessorDeclSyntax(
            accessorSpecifier: .keyword(.set),
            body: CodeBlockSyntax {
                "self[\(keyName).self] = newValue"
            }
        )
    }
    
    private static func makeKeyName(
        from propertyName: PatternSyntax
    ) -> TokenSyntax {
        return "ConfigurationKey_\(propertyName)"
    }
    
    internal static func makeAccessors(
        from propertyName: PatternSyntax
    ) -> [AccessorDeclSyntax] {
        let keyName = makeKeyName(from: propertyName)
        return [
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.get),
                body: CodeBlockSyntax {
                    "return self[\(keyName).self]"
                }
            ),
            makeSetAccessor(keyName: keyName)
        ]
    }
    
    internal static func makeUnwrappedAccessors(
        propertyName: PatternSyntax,
        type: TypeSyntax?
    ) -> [AccessorDeclSyntax] {
        let keyName = makeKeyName(from: propertyName)
        let message: DeclSyntax = """
        "Missing configuration of type: '\(type ?? "")'. Make sure you're setting a value for the key '\(propertyName)' before using it."
        """
        return [
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.get),
                body: CodeBlockSyntax {
                    "let value = self[\(keyName).self]"
                    """
                    precondition(
                        value != nil,
                        \(message)
                    )
                    """
                    "return value!"
                }
            ),
            makeSetAccessor(keyName: keyName)
        ]
    }
    
    internal static func makeKeyDecl(
        propertyName: PatternSyntax,
        binding: PatternBindingSyntax,
        forced: Bool,
        optional: Bool
    ) -> [DeclSyntax] {
        let accessLevel = DeclModifierSyntax(name: .keyword(.fileprivate))
        var binding = binding
        binding.pattern = PatternSyntax(
            IdentifierPatternSyntax(identifier: .identifier("defaultValue"))
        )
        
        if (optional || forced) && binding.initializer == nil {
            binding.initializer = InitializerClauseSyntax(value: NilLiteralExprSyntax())
        }
        binding.typeAnnotation = binding.typeAnnotation.map {
            if forced {
                return TypeAnnotationSyntax(
                    type: OptionalTypeSyntax(
                        wrappedType: TupleTypeSyntax(elements: [
                            TupleTypeElementSyntax(type: $0.type)
                        ])
                    )
                )
            }else {
                return TypeAnnotationSyntax(
                    type: $0.type
                )
            }
        }
        
        let structDecl = StructDeclSyntax(
            modifiers: [accessLevel],
            name: makeKeyName(from: propertyName),
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: [
                    InheritedTypeSyntax(type: TypeSyntax("ConfigurationKey"))
                ]
            ),
            memberBlock: MemberBlockSyntax {
                VariableDeclSyntax(
                    modifiers: [
                        accessLevel,
                        DeclModifierSyntax(name: .keyword(.static))
                    ],
                    bindingSpecifier: .keyword(.let),
                    bindings: [binding]
                )
            }
        )
        return [DeclSyntax(structDecl)]
    }
}
