//
//  DeclarationAccessLevel.swift
//
//
//  Created by Joe Maghzal on 08/06/2024.
//

import SwiftSyntax

public enum AccessLevel: CaseIterable {
    case `public`, `package`, `internal`, `private`, `fileprivate`
    
    public var name: TokenSyntax {
        switch self {
            case .public:
                return "public"
            case .package:
                return "package"
            case .internal:
                return "internal"
            case .private:
                return "private"
            case .fileprivate:
                return "fileprivate"
        }
    }
    
    public var modifier: TokenSyntax {
        return "\(name) "
    }
}

extension DeclModifierListSyntax {
    public var accessLevel: AccessLevel? {
        return compactMap { modifier in
            let tokenKind = modifier.name.tokenKind
            guard case .keyword(let keyword) = tokenKind else {
                return nil
            }
            return keyword.accessLevel
            
        }.first
    }
}

extension Keyword {
    public var accessLevel: AccessLevel? {
        switch self {
            case .public:
                return .public
            case .package:
                return .package
            case .internal:
                return .internal
            case .private:
                return .private
            case .fileprivate:
                return .fileprivate
            default:
                return nil
        }
    }
}
