//
//  Task+TypedThrows.swift
//  Networking
//
//  Created by Joe Maghzal on 18/07/2025.
//

import Foundation
import NetworkingCore

extension Task where Failure == Never, Success == Never {
    /// Checks for task cancellation and throws a typed ``NetworkingError.cancellation`` if cancelled.
    ///
    /// This method wraps ``Task.checkCancellation()`` and converts a thrown ``CancellationError``
    /// into a ``NetworkingError.cancellation``, enabling consistent error handling across the framework.
    ///
    /// - Throws: ``NetworkingError.cancellation`` if the task has been cancelled.
    package static func checkTypedCancellation() throws(NetworkingError) {
        do {
            try Self.checkCancellation()
        }catch {
            throw .cancellation
        }
    }
}

extension Task where Failure == any Error {
    /// Returns the task result or throws a ``NetworkingError`` if the task failed.
    ///
    /// This computed property allows consumers to access the `value` of a task while ensuring that
    /// any thrown error is normalized into a ``NetworkingError``. It is particularly useful in
    /// `async`/`await` flows that require consistent error types.
    ///
    /// - Returns: The successful result of the task.
    /// - Throws: A ``NetworkingError`` if the task fails.
    package var typedValue: Success {
        get async throws(NetworkingError) {
            do {
                return try await value
            }catch {
                throw error.networkingError
            }
        }
    }
}
