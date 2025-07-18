//
//  EmptyModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 17/05/2025.
//

import Foundation

@frozen public struct EmptyModifier {
    @inlinable public init() { }
}

// MARK: - RequestModifier
extension EmptyModifier: RequestModifier {
    @inlinable public func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        return request
    }
}

// MARK: - _DynamicConfigurable
extension EmptyModifier: _DynamicConfigurable {
    @_spi(Internal) @inlinable public func _accept(_ values: ConfigurationValues) { }
}

// MARK: - CustomStringConvertible
extension EmptyModifier: CustomStringConvertible {
    public var description: String {
        return "EmptyModifier"
    }
}

// MARK: - RequestHeader
extension EmptyModifier: RequestHeader {
    @inlinable public var headers: [String : String] {
        return [:]
    }
}

// MARK: - RequestParameter
extension EmptyModifier: RequestParameter {
    @inlinable public var parameters: [URLQueryItem] {
        return []
    }
}
