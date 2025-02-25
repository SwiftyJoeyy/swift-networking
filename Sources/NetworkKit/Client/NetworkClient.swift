//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/21/25.
//

import Foundation

// TODO: - Add support for background
public protocol NetworkClient {
    var _command: RequestCommand! {get set}
    var command: RequestCommand {get}
}

extension NetworkClient {
    public mutating func configure() {
        _command = command
    }
    
    @inline(__always) public func dataTask(
        _ request: consuming some Request
    ) throws -> DataTask {
        return try _command.dataTask(request)
    }
    @inline(__always) public func downloadTask(
        _ request: consuming some Request
    ) throws -> DownloadTask {
        return try _command.downloadTask(request)
    }
}
