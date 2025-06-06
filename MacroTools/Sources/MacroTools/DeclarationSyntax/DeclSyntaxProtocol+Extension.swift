//
//  DeclSyntaxProtocol+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 06/06/2025.
//

import SwiftSyntax

extension DeclSyntaxProtocol {
    /// Retrieves the declaration as a `DeclarationSyntax`
    /// if it conforms to any known declaration syntax types.
    public var declaration: (any DeclarationSyntax)? {
        if let declaration = self.as(StructDeclSyntax.self) {
            return declaration
        }
        if let declaration = self.as(ClassDeclSyntax.self) {
            return declaration
        }
        if let declaration = self.as(ActorDeclSyntax.self) {
            return declaration
        }
        if let declaration = self.as(EnumDeclSyntax.self) {
            return declaration
        }
        if let declaration = self.as(ProtocolDeclSyntax.self) {
            return declaration
        }
        
        return nil
    }
    
    /// Retrieves the type name as a ``TokenSyntax`` from the declaration.
    public var typeName: TokenSyntax? {
        guard let declaration = declaration else {
            return nil
        }
        return declaration.name
    }
    
    /// Retrieves the inherited types from the declaration's inheritance clause.
    public var inheritedTypes: InheritedTypeListSyntax? {
        guard let declaration = declaration else {
            return nil
        }
        return declaration.inheritanceClause?.inheritedTypes
    }
}
