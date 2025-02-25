//
//  StatusValidator.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

public protocol StatusValidator: Sendable {
    func validate(_ task: any NetworkingTask, status: ResponseStatus) async throws
}

extension StatusValidator where Self == DefaultStatusValidator {
    public static var none: Self {
        return DefaultStatusValidator(validStatuses: [])
    }
}

public struct DefaultStatusValidator: StatusValidator {
    private let handler: (
        @Sendable (
            _ status: ResponseStatus,
            _ task: any NetworkingTask
        ) async -> (any Error)?
    )?
    private let validStatuses: Set<ResponseStatus>
    
    internal init(
        validStatuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: (
            @Sendable (
                _ status: ResponseStatus,
                _ task: any NetworkingTask
            ) async -> (any Error)?
        )? = nil
    ) {
        self.validStatuses = validStatuses
        self.handler = handler
    }
    
    public func validate(
        _ task: any NetworkingTask,
        status: ResponseStatus
    ) async throws {
        let valid = validStatuses.contains(status)
        guard !valid else {return}
        
        if let error = await handler?(status, task) {
            throw error
        }
        throw NKError.unacceptableStatusCode(status)
    }
}
