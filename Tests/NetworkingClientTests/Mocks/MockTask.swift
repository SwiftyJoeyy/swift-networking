//
//  MockTask.swift
//  Networking
//
//  Created by Joe Maghzal on 6/4/25.
//

import Foundation
@testable import NetworkingCore
@_spi(Internal) @testable import NetworkingClient

actor MockTask: NetworkingTask, Equatable {
    let id = UUID().uuidString
    let retryCount = 0
    let metrics: URLSessionTaskMetrics? = nil
    let configurations = ConfigurationValues()
    let request: URLRequest
    var isCancelled = false
    var taskSet: URLSessionTask?
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func cancel() async -> Self {
        isCancelled = true
        return self
    }
    func resume() async -> Self {
        return self
    }
    func suspend() async -> Self {
        return self
    }
    func _set(_ task: URLSessionTask) async {
        taskSet = task
    }
    
    static func == (lhs: MockTask, rhs: MockTask) -> Bool {
        return lhs.id == rhs.id
    }
}
