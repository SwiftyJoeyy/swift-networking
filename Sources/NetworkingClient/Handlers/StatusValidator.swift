//
//  StatusValidator.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

public protocol StatusValidator: Sendable {
    var validStatuses: Set<ResponseStatus> {get}
    func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus
    ) async throws
}

extension StatusValidator {
    public func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus
    ) async throws { }
    
    internal func _validate(
        _ task: any NetworkingTask,
        status: ResponseStatus
    ) async throws {
        let valid = validStatuses.contains(status)
        guard !valid else {return}
        if status == .unauthorized {
            throw NetworkingError.ClientError.unauthorized
        }
        try await validate(task, status: status)
        throw NetworkingError.ClientError.unacceptableStatusCode(status)
    }
}

extension StatusValidator where Self == DefaultStatusValidator {
    public static var none: Self {
        return DefaultStatusValidator(validStatuses: [])
    }
}

public struct DefaultStatusValidator: StatusValidator {
    public typealias Handler = @Sendable (
        _ status: ResponseStatus,
        _ task: any NetworkingTask
    ) async -> (any Error)?
    
// MARK: - Properties
    private let handler: Handler?
    public let validStatuses: Set<ResponseStatus>
    
// MARK: - Initializer
    internal init(
        validStatuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: Handler? = nil
    ) {
        self.validStatuses = validStatuses
        self.handler = handler
    }
    
// MARK: - StatusValidator
    public func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus
    ) async throws {
        guard let error = await handler?(status, task) else {return}
        throw error
    }
}
