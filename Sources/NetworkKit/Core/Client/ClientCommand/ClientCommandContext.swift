//
//  ClientCommandContext.swift
//  
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

public struct ClientCommandContext {
    public internal(set) var result: Result<RequestResultType, Error>?
    public internal(set) var statusCode: ResponseStatus?
    public internal(set) var currentRetryCount: Int
    public internal(set) var state: State
    public internal(set) var task: RequestTask
}

extension ClientCommandContext {
    static func initial(task: RequestTask) -> Self {
        return ClientCommandContext(currentRetryCount: 0, state: .procceed, task: task)
    }
}

//MARK: - Modifiers
extension ClientCommandContext {
    @inline(__always)
    public func retry() -> Self {
        let retryCount = currentRetryCount + 1
        let context = ClientCommandContext(currentRetryCount: retryCount, state: .stopAndRetry, task: task)
        return context
    }
    
    @inline(__always)
    public func stop() -> Self {
        return withState(.stop)
    }
    
    @inline(__always)
    public func procceed() -> Self {
        return withState(.procceed)
    }
    
    public func with(
        result: Result<RequestResultType, Error>?,
        statusCode: ResponseStatus? = nil
    ) -> Self {
        var context = self
        context.result = result
        context.statusCode = statusCode
        return context
    }
    
    public func withState(_ state: State) -> Self {
        var context = self
        context.state = state
        return context
    }
}

//MARK: - State
extension ClientCommandContext {
    public enum State: Equatable, Hashable {
        case stop, procceed, stopAndRetry
    }
}
