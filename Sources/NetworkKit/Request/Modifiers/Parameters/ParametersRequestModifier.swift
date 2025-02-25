//
//  ParametersRequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

@usableFromInline internal struct ParametersRequestModifier {
    private let parameters: any RequestParameter
    
    @usableFromInline internal init(_ parameters: any RequestParameter) {
        self.parameters = parameters
    }
}

// MARK: - RequestModifier
extension ParametersRequestModifier: RequestModifier {
    @usableFromInline @inline(__always)
    internal func modified(_ request: consuming URLRequest) throws -> URLRequest {
        return try parameters.modified(consume request)
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public func additionalParameters(
        @ParametersBuilder _ parameters: () -> ParametersGroup
    ) -> some Request {
        modifier(ParametersRequestModifier(parameters()))
    }
}
