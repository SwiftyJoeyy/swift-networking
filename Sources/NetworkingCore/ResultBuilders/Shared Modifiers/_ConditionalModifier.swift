//
//  _ConditionalModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 17/05/2025.
//

import Foundation

@frozen public struct _ConditionalModifier<TrueContent, FalseContent> {
    @frozen public enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }
    public let storage: Self.Storage
    
    @inlinable public init(storage: Self.Storage) {
        self.storage = storage
    }
}

// MARK: - RequestModifier
extension _ConditionalModifier: RequestModifier where TrueContent: RequestModifier, FalseContent: RequestModifier {
    @inlinable public func modifying(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        switch storage {
            case .trueContent(let mod):
                return try mod.modifying(request)
            case .falseContent(let mod):
                return try mod.modifying(request)
        }
    }
}

// MARK: - _DynamicConfigurable
extension _ConditionalModifier: _DynamicConfigurable where TrueContent: _DynamicConfigurable, FalseContent: _DynamicConfigurable {
    @inlinable public func _accept(_ values: ConfigurationValues) {
        switch storage {
            case .trueContent(let mod):
                mod._accept(values)
            case .falseContent(let mod):
                mod._accept(values)
        }
    }
}

// MARK: - CustomStringConvertible
extension _ConditionalModifier: CustomStringConvertible where TrueContent: CustomStringConvertible, FalseContent: CustomStringConvertible {
    public var description: String {
        switch storage {
            case .trueContent(let content):
                return content.description
            case .falseContent(let content):
                return content.description
        }
    }
}

// MARK: - RequestHeader
extension _ConditionalModifier: RequestHeader where TrueContent: RequestHeader, FalseContent: RequestHeader {
    @inlinable public var headers: [String : String] {
        switch storage {
            case .trueContent(let header):
                return header.headers
            case .falseContent(let header):
                return header.headers
        }
    }
}

// MARK: - RequestParameter
extension _ConditionalModifier: RequestParameter where TrueContent: RequestParameter, FalseContent: RequestParameter {
    @inlinable public var parameters: [URLQueryItem] {
        switch storage {
            case .trueContent(let parameter):
                return parameter.parameters
            case .falseContent(let parameter):
                return parameter.parameters
        }
    }
}
