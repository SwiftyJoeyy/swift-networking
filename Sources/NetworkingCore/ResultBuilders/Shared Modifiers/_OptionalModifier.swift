//
//  _OptionalModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 17/05/2025.
//

import Foundation

@frozen public struct _OptionalModifier<Modifier> {
    public let storage: Modifier?
    
    @inlinable public init(storage: Modifier?) {
        self.storage = storage
    }
}

// MARK: - RequestModifier
extension _OptionalModifier: RequestModifier where Modifier: RequestModifier {
    @inlinable public func modifying(
        _ request: consuming URLRequest
    ) throws -> URLRequest {
        guard let storage else {
            return request
        }
        return try storage.modifying(request)
    }
}

// MARK: - _DynamicConfigurable
extension _OptionalModifier: _DynamicConfigurable where Modifier: _DynamicConfigurable {
    @inlinable public func _accept(_ values: ConfigurationValues) {
        storage?._accept(values)
    }
}

// MARK: - CustomStringConvertible
extension _OptionalModifier: CustomStringConvertible where Modifier: CustomStringConvertible {
    public var description: String {
        return storage?.description ?? "Empty"
    }
}

// MARK: - RequestHeader
extension _OptionalModifier: RequestHeader where Modifier: RequestHeader {
    @inlinable public var headers: [String : String] {
        return storage?.headers ?? [:]
    }
}

// MARK: - RequestParameter
extension _OptionalModifier: RequestParameter where Modifier: RequestParameter {
    @inlinable public var parameters: [URLQueryItem] {
        return storage?.parameters ?? []
    }
}
