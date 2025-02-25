//
//  RequestModifier.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 1/16/25.
//

import Foundation

public typealias RequestModifiersBuilder = AnyResultBuilder<any RequestModifier>

public protocol RequestModifier {
    func modified(_ request: consuming URLRequest) throws -> URLRequest
}

@usableFromInline internal struct ModifiedRequest<T: Request>: Request {
    @usableFromInline internal let request: T
    @usableFromInline internal var _modifiers: [any RequestModifier]
    
    @usableFromInline internal init(request: consuming T, _modifiers: consuming any RequestModifier) {
        self.request = request
        self._modifiers = [_modifiers]
    }
}

// MARK: - Modifier
extension Request {
    @inlinable public consuming func modifier(
        _ modifier: consuming some RequestModifier
    ) -> some Request {
        ModifiedRequest(request: consume self, _modifiers: consume modifier)
    }
}
