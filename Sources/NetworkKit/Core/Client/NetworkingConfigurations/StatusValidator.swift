//
//  File.swift
//  
//
//  Created by Joe Maghzal on 15/06/2024.
//

import Foundation

public protocol StatusValidator: ClientCommand {
    func validate(_ status: ResponseStatus) -> Error?
}

extension StatusValidator {
    public func execute(request: some Request, with context: ClientCommandContext) async -> ClientCommandContext {
        guard let statusCode = context.statusCode,
              let error = validate(statusCode)
        else {
            return context
        }
        return context.with(result: .failure(error), statusCode: statusCode)
    }
}

struct DefaultStatusValidator: StatusValidator {
    var validStatuses: [ResponseStatus] = [
        .ok,
        .created,
        .accepted,
        .nonAuthoritativeInformation,
        .noContent,
        .resetContent,
        .partialContent,
        .multiStatus,
        .alreadyReported,
        .imUsed
    ]
    
    func validate(_ status: ResponseStatus) -> Error? {
        let valid = validStatuses.contains(status)
        guard !valid else {
            return nil
        }
        return NKError.unacceptableStatusCode(status)
    }
}
