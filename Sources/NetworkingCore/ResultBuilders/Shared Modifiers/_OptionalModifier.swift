//
//  _OptionalModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 17/05/2025.
//

import Foundation

@frozen public struct _OptionalModifier<Modifier> {
    public let storage: Modifier?
    
    public init(storage: Modifier?) {
        self.storage = storage
    }
}

// MARK: - RequestModifier
extension _OptionalModifier: RequestModifier where Modifier: RequestModifier {
    public func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        guard let storage else {
            return request
        }
        return try storage.modifying(consume request)
    }
}

// MARK: - _DynamicConfigurable
extension _OptionalModifier: _DynamicConfigurable where Modifier: _DynamicConfigurable {
    @_spi(Internal) public func _accept(_ values: ConfigurationValues) {
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
    public var headers: [String : String] {
        return storage?.headers ?? [:]
    }
}

// MARK: - RequestParameter
extension _OptionalModifier: RequestParameter where Modifier: RequestParameter {
    public var parameters: [URLQueryItem] {
        return storage?.parameters ?? []
    }
}
