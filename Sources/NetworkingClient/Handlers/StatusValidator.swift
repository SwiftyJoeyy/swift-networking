//
//  StatusValidator.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

public protocol StatusValidator: ResponseInterceptor, Sendable {
    func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus,
        with context: borrowing Context
    ) async throws
}

extension StatusValidator {
    public func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws -> RequestContinuation {
        guard let status = context.status,
              context.error == nil
        else {
            return .continue
        }
        
        do {
            try await validate(task, status: status, with: context)
        }catch {
            return .failure(error)
        }
        return .continue
    }
}

public struct DefaultStatusValidator: StatusValidator {
    public typealias Handler = @Sendable (
        _ task: any NetworkingTask,
        _ status: ResponseStatus,
        _ context: borrowing Context
    ) async throws -> Void
    
    private let validStatuses: Set<ResponseStatus>
    private let handler: Handler?
    
    public init(
        validStatuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: Handler? = nil
    ) {
        self.validStatuses = validStatuses
        self.handler = handler
    }
    
    public func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus,
        with context: borrowing Context
    ) async throws {
        if !validStatuses.contains(status) {
            throw NetworkingError.ClientError.unacceptableStatusCode(status)
        }
        try await handler?(task, status, context)
    }
}

extension Configurable {
    /// Sets the validator used to validate HTTP response statuses.
    public func validate(_ validator: some StatusValidator) -> Self {
        return configuration(\.statusValidator, validator)
    }
    
    /// Sets the validator used to validate HTTP response statuses.
    public func unvalidated() -> Self {
        return configuration(\.statusValidator, nil)
    }
    
    /// Sets the validator used to validate HTTP response statuses.
    ///
    /// - Parameters:
    ///   - statuses: A set of valid response statuses.
    ///   - handler: An optional closure executed when a status needs validation.
    public func validate(
        for statuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: DefaultStatusValidator.Handler? = nil
    ) -> Self {
        let validator = DefaultStatusValidator(
            validStatuses: statuses,
            handler
        )
        return validate(validator)
    }
}
