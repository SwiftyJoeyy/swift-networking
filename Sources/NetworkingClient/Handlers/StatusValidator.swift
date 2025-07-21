//
//  StatusValidator.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

/// An interceptor that validates HTTP response status codes.
///
/// Conforming to ``StatusValidator`` allows a type to inspect
/// and validate the status of a received response before continuing
/// request processing.
///
/// You can provide a custom implementation or use
/// ``DefaultStatusValidator`` to check for acceptable status codes.
///
/// Validation occurs only if a status is present and no error is already set.
///
/// Use the ``Configurable/validate(_:)`` modifier to attach a validator to a request.
public protocol StatusValidator: ResponseInterceptor, Sendable {
    /// Validates the response status for the given task and context.
    ///
    /// - Parameters:
    ///   - task: The current networking task.
    ///   - status: The response status to validate.
    ///   - context: The current request context.
    ///
    /// - Throws: A ``NetworkingError`` if request construction fails.
    func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus,
        with context: borrowing Context
    ) async throws(StatusError)
}

extension StatusValidator {
    /// Intercepts the response to perform status validation.
    ///
    /// This implementation calls ``StatusValidator/validate(_:status:with:)``
    /// if the response has a valid status and no prior error.
    ///
    /// - Returns: `.continue` if the status is valid, `.failure(error)` if validation throws.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    public func intercept(
        _ task: some NetworkingTask,
        for session: Session,
        with context: borrowing Context
    ) async throws(NetworkingError) -> RequestContinuation {
        guard let status = context.status,
              context.error == nil
        else {
            return .continue
        }
        
        do throws(StatusError) {
            try await validate(task, status: status, with: context)
        }catch {
            return .failure(NetworkingError.client(.status(error)))
        }
        return .continue
    }
}

/// A default implementation of ``StatusValidator`` that checks response status codes.
///
/// Use `DefaultStatusValidator` to verify that the response status
/// is within a predefined set of acceptable values. You can optionally provide
/// a custom validation handler.
///
/// This validator throws ``NetworkingError/ClientError/unacceptableStatusCode(_:)``
/// if the status code is not in the accepted set.
///
/// Use with ``Configurable/validate(for:_:)`` or ``Configurable/validate(_:)``.
public struct DefaultStatusValidator: StatusValidator {
    /// A closure that performs custom validation after the status is accepted.
    public typealias Handler = @Sendable (
        _ task: any NetworkingTask,
        _ status: ResponseStatus,
        _ context: borrowing Context
    ) async throws(StatusError) -> Void
    
    /// A set of predefined acceptable statuses.
    private let validStatuses: Set<ResponseStatus>
    
    /// The handler used to perform custom validation after the status is accepted.
    private let handler: Handler?
    
    /// Creates a new status validator.
    ///
    /// - Parameters:
    ///   - validStatuses: A set of status codes considered acceptable.
    ///   - handler: An optional closure to perform additional validation.
    public init(
        validStatuses: Set<ResponseStatus> = ResponseStatus.validStatuses,
        _ handler: Handler? = nil
    ) {
        self.validStatuses = validStatuses
        self.handler = handler
    }
    
    /// Validates the response status for the given task and context.
    ///
    /// - Parameters:
    ///   - task: The current networking task.
    ///   - status: The response status to validate.
    ///   - context: The current request context.
    ///
    /// - Throws: A ``NetworkingError`` if request construction fails.
    public func validate(
        _ task: some NetworkingTask,
        status: ResponseStatus,
        with context: borrowing Context
    ) async throws(StatusError) {
        if !validStatuses.contains(status) {
            throw StatusError(status: status)
        }
        try await handler?(task, status, context)
    }
}
