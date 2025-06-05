//
//  RequestMethod.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Type that represents the HTTP request methods supported by the client.
///
/// Use request methods to indicate the desired action to be performed for a given resource.
/// Common methods include `GET` to retrieve data and `POST` to submit data to the server.
@frozen public enum RequestMethod: String, Equatable, Hashable, Sendable, CaseIterable {
    case get = "GET"
    case put = "PUT"
    case head = "HEAD"
    case post = "POST"
    case copy = "COPY"
    case lock = "LOCK"
    case move = "MOVE"
    case bind = "BIND"
    case link = "LINK"
    case patch = "PATCH"
    case trace = "TRACE"
    case merge = "MERGE"
    case purge = "PURGE"
    case notify = "NOTIFY"
    case search = "SEARCH"
    case unlock = "UNLOCK"
    case rebind = "REBIND"
    case unbind = "UNBIND"
    case report = "REPORT"
    case delete = "DELETE"
    case unlink = "UNLINK"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case checkout = "CHECKOUT"
    case subscribe = "SUBSCRIBE"
    case unsubscribe = "UNSUBSCRIBE"
    case source = "SOURCE"
}

// MARK: - CustomStringConvertible
extension RequestMethod: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
