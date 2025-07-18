//
//  _TupleModifier.swift
//  Networking
//
//  Created by Joe Maghzal on 17/05/2025.
//

import Foundation

@frozen public struct _TupleModifier<M0, M1, M2, M3, M4, M5, M6, M7, M8, M9> {
    public let value: (M0, M1, M2, M3, M4, M5, M6, M7, M8, M9)
}

// MARK: - RequestModifier
extension _TupleModifier: RequestModifier where M0: RequestModifier, M1: RequestModifier, M2: RequestModifier, M3: RequestModifier, M4: RequestModifier, M5: RequestModifier, M6: RequestModifier, M7: RequestModifier, M8: RequestModifier, M9: RequestModifier {
    
    public init(
        _ m0: M0,
        _ m1: M1,
        _ m2: M2 = EmptyModifier(),
        _ m3: M3 = EmptyModifier(),
        _ m4: M4 = EmptyModifier(),
        _ m5: M5 = EmptyModifier(),
        _ m6: M6 = EmptyModifier(),
        _ m7: M7 = EmptyModifier(),
        _ m8: M8 = EmptyModifier(),
        _ m9: M9 = EmptyModifier()
    ) {
        self.value = (m0, m1, m2, m3, m4, m5, m6, m7, m8, m9)
    }
    
    public func modifying(
        _ request: consuming URLRequest
    ) throws(NetworkingError) -> URLRequest {
        var urlRequest = try value.0.modifying(consume request)
        urlRequest = try value.1.modifying(consume urlRequest)
        urlRequest = try value.2.modifying(consume urlRequest)
        urlRequest = try value.3.modifying(consume urlRequest)
        urlRequest = try value.4.modifying(consume urlRequest)
        urlRequest = try value.5.modifying(consume urlRequest)
        urlRequest = try value.6.modifying(consume urlRequest)
        urlRequest = try value.7.modifying(consume urlRequest)
        urlRequest = try value.8.modifying(consume urlRequest)
        urlRequest = try value.9.modifying(consume urlRequest)
        return urlRequest
    }
}

// MARK: - _DynamicConfigurable
extension _TupleModifier: _DynamicConfigurable where M0: _DynamicConfigurable, M1: _DynamicConfigurable, M2: _DynamicConfigurable, M3: _DynamicConfigurable, M4: _DynamicConfigurable, M5: _DynamicConfigurable, M6: _DynamicConfigurable, M7: _DynamicConfigurable, M8: _DynamicConfigurable, M9: _DynamicConfigurable {
    
    @_spi(Internal) public func _accept(_ values: ConfigurationValues) {
        value.0._accept(values)
        value.1._accept(values)
        value.2._accept(values)
        value.3._accept(values)
        value.4._accept(values)
        value.5._accept(values)
        value.6._accept(values)
        value.7._accept(values)
        value.8._accept(values)
        value.9._accept(values)
    }
}

// MARK: - CustomStringConvertible
extension _TupleModifier: CustomStringConvertible where M0: CustomStringConvertible, M1: CustomStringConvertible, M2: CustomStringConvertible, M3: CustomStringConvertible, M4: CustomStringConvertible, M5: CustomStringConvertible, M6: CustomStringConvertible, M7: CustomStringConvertible, M8: CustomStringConvertible, M9: CustomStringConvertible {
    
    public var description: String {
        let values = [
            value.0.description, value.1.description, value.2.description, value.3.description, value.4.description,
            value.5.description, value.6.description, value.7.description, value.8.description, value.9.description
        ].joined(separator: ", ")
        
        return """
        \(String(describing: Self.self)) = {
            [\(values)]
        }
        """
    }
}

// MARK: - RequestParameter
extension _TupleModifier: RequestParameter where M0: RequestParameter, M1: RequestParameter, M2: RequestParameter, M3: RequestParameter, M4: RequestParameter, M5: RequestParameter, M6: RequestParameter, M7: RequestParameter, M8: RequestParameter, M9: RequestParameter {
    public var parameters: [URLQueryItem] {
        return value.0.parameters + value.1.parameters + value.2.parameters + value.3.parameters + value.4.parameters + value.5.parameters + value.6.parameters + value.7.parameters + value.8.parameters + value.9.parameters
    }
}

// MARK: - RequestHeader
extension _TupleModifier: RequestHeader where M0: RequestHeader, M1: RequestHeader, M2: RequestHeader, M3: RequestHeader, M4: RequestHeader, M5: RequestHeader, M6: RequestHeader, M7: RequestHeader, M8: RequestHeader, M9: RequestHeader {
    
    public var headers: [String : String] {
        value.0.headers
            .merging(value.1.headers, uniquingKeysWith: { $1 })
            .merging(value.2.headers, uniquingKeysWith: { $1 })
            .merging(value.3.headers, uniquingKeysWith: { $1 })
            .merging(value.4.headers, uniquingKeysWith: { $1 })
            .merging(value.5.headers, uniquingKeysWith: { $1 })
            .merging(value.6.headers, uniquingKeysWith: { $1 })
            .merging(value.7.headers, uniquingKeysWith: { $1 })
            .merging(value.8.headers, uniquingKeysWith: { $1 })
            .merging(value.9.headers, uniquingKeysWith: { $1 })
    }
}
