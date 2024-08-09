//
//  ModifiedRequest.swift
//  
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

public protocol RequestModifier {
    func modified(request: URLRequest) throws -> URLRequest
}

fileprivate struct ModifiedRequest<T: Request> {
    private let modifiableRequest: T
    fileprivate var modifiers: [RequestModifier]
    
    fileprivate init(modifiableRequest: T, modifiers: [RequestModifier]) {
        self.modifiableRequest = modifiableRequest
        self.modifiers = modifiers
    }
}

//MARK: - Request
extension ModifiedRequest: Request {
    fileprivate var request: some Request {
        modifiableRequest
    }
}

//MARK: - Modifier
extension Request {
    public func modifier(_ modifier: some RequestModifier) -> some Request {
        ModifiedRequest(modifiableRequest: self, modifiers: [modifier])
    }
    public func modifiers(@RequestModifiersBuilder _ modifiers: () -> [RequestModifier]) -> some Request {
        ModifiedRequest(modifiableRequest: self, modifiers: modifiers())
    }
}
