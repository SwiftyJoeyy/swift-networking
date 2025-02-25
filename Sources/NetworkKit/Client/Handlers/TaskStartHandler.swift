//
//  TaskStartHandler.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/24/25.
//

import Foundation

public protocol TaskStartHandler: Sendable {
    func willStart(_ task: any NetworkingTask) async throws
}

extension TaskStartHandler where Self == DefaultTaskStartHandler {
    public static var none: Self {
        return DefaultTaskStartHandler()
    }
}

public struct DefaultTaskStartHandler: TaskStartHandler {
    private let handler: (@Sendable (_ task: any NetworkingTask) async throws -> Void)?
    
    internal init(
        _ handler: (@Sendable (_ task: any NetworkingTask) async throws -> Void)? = nil
    ) {
        self.handler = handler
    }
    
    public func willStart(_ task: any NetworkingTask) async throws {
        try await handler?(task)
    }
}
