//
//  SessionTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/10/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite struct SessionTests {
    private let storage = MockTasksStorage()
    private let delegate = SessionDelegate()
    
    @Test func initSetsTasksStorageToDelegateAndConfigurations() async {
        let session = Session(
            sessionDelegate: delegate,
            configuration: .default,
            tasksStorage: storage
        )
    
        #expect(session.configurations.tasks === storage)
        await #expect(session.delegate.tasks === storage)
    }
    
    @Test func initConfiguresURLSession() async {
        let queue = OperationQueue()
        let configuration = URLSessionConfiguration.default
        let session = Session(
            sessionDelegate: delegate,
            configuration: configuration,
            delegateQueue: queue,
            tasksStorage: storage
        )
        
        let urlSession = await session.session
        #expect(urlSession.delegate === delegate)
        #expect(urlSession.delegateQueue === queue)
    }
    
    @Test func initWithClosureSetsConfigurations() async {
        let session = Session(
            sessionDelegate: delegate,
            tasksStorage: storage
        ) {
            URLSessionConfiguration.default
                .headers {
                    Header("test", value: "value")
                }
        }
    
        let headers = await session.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(headers?["test"] == "value")
    }
    
    @Test func cancelAll() async throws {
        let session = Session(
            sessionDelegate: delegate,
            configuration: .default,
            tasksStorage: storage
        )
        
        await session.cancelAll()
        let cancelled = await storage.cancelled
        #expect(cancelled)
    }
    
    @Test func configurationModifier() async throws {
        let url = URL(string: "example.com")
        let session = Session()
        
        let updated = session.configuration(\.baseURL, url)
        
        #expect(session === updated)
        #expect(updated.configurations.baseURL == url)
    }
    
    @Test func creatingTaskFromRequestWithID() {
        let session = Session()
        let request = TestRequest(id: "test-request")
        let dataTask = session.dataTask(request)
        let downloadTask = session.downloadTask(request)
        
        #expect(dataTask.id == request.id)
        #expect(downloadTask.id == request.id)
    }
    
    @Test func creatingTaskFromRequestWithoutID() {
        let session = Session()
        let request = TestRequest()
        let dataTask = session.dataTask(request)
        let downloadTask = session.downloadTask(request)
        
        #expect(dataTask.id == "TestRequest")
        #expect(downloadTask.id == "TestRequest")
    }
    
    @Test func creatingTaskSetsConfigurations() async {
        let url = URL(string: "example.com/testing/sesion")
        let session = Session()
            .baseURL(url)
        let dataTask = session.dataTask(TestRequest())
        let downloadTask = session.downloadTask(TestRequest())
        
        #expect(dataTask.configurations.baseURL == url)
        #expect(downloadTask.configurations.baseURL == url)
    }
}
