//
//  ErrorHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

public protocol ErrorHandler: Sendable {
    func handle(_ error: any Error, for task: any NetworkingTask) async
}

extension ErrorHandler where Self == DefaultErrorHandler {
    public static var none: Self {
        return DefaultErrorHandler()
    }
}

public struct DefaultErrorHandler: ErrorHandler {
    private let handler: (@Sendable (_ error: any Error, _ task: any NetworkingTask) async -> Void)?
    
    internal init(
        _ handler: (@Sendable (_ error: any Error, _ task: any NetworkingTask) async -> Void)? = nil
    ) {
        self.handler = handler
    }
    
    public func handle(_ error: any Error, for task: any NetworkingTask) async {
        await handler?(error, task)
    }
}
