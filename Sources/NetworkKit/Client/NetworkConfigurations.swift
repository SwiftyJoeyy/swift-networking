//
//  NetworkConfigurations.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/12/25.
//

import Foundation

public struct NetworkConfigurations: Sendable {
    public let tasks: any TasksStorage
    public var decoder = JSONDecoder()
    public var encoder = JSONEncoder()
    public var url: URL?
    public var handlers = NetworkHandlers()
    public var logsEnabled = true
    public var backgroundTasksEnabled = false
}

public struct NetworkHandlers: Sendable {
    public var redirectionHandler: any RedirectionHandler = DefaultRedirectionHandler()
    public var errorHandler: any ErrorHandler = DefaultErrorHandler()
    public var statusValidator: any StatusValidator = DefaultStatusValidator()
    public var retryPolicy: any RetryPolicy = DefaultRetryPolicy()
    public var cacheHandler: any ResponseCacheHandler = DefaultResponseCacheHandler()
    public var startHandler: any TaskStartHandler = DefaultTaskStartHandler()
}
