//
//  TimeoutRequestModifier.swift
//
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

fileprivate struct TimeoutRequestModifier {
    private let timeoutInterval: TimeInterval
    
    fileprivate init(_ timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
}

//MARK: - RequestModifier
extension TimeoutRequestModifier: RequestModifier {
    fileprivate func modified(request: URLRequest) throws -> URLRequest {
        var newRequest = request
        newRequest.timeoutInterval = timeoutInterval
        return newRequest
    }
}

//MARK: - Modifier
extension Request {
    public func timeout(_ timeoutInterval: TimeInterval) -> some Request {
        modifier(TimeoutRequestModifier(timeoutInterval))
    }
}
