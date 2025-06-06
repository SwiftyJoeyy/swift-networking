//
//  DeclarationSyntax.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

/// Protocol representing a declaration syntax element in Swift.
package protocol DeclarationSyntax {
    /// The name of the type.
    var name: TokenSyntax {get}
    
    /// The inheritance clause of the type, if any.
    var inheritanceClause: InheritanceClauseSyntax? {get}
    
    /// The list of modifiers applied to the type.
    var modifiers: DeclModifierListSyntax {get}
}

extension StructDeclSyntax: DeclarationSyntax { }

extension ClassDeclSyntax: DeclarationSyntax { }

extension ActorDeclSyntax: DeclarationSyntax { }

extension EnumDeclSyntax: DeclarationSyntax { }

extension ProtocolDeclSyntax: DeclarationSyntax { }

