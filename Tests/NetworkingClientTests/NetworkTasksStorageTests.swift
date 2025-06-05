//
//  NetworkTasksStorageTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/10/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite struct NetworkTasksStorageTests {
    @Test func addAndRetrieveTask() async throws {
        let storage = NetworkTasksStorage()
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let task = MockTask(request: request)
        
        await storage.add(task, for: task.request)
        let retrieved = await storage.task(for: task.request)
        
        #expect(retrieved as? MockTask == task)
    }
    
    @Test func retrieveNonExistentTask() async throws {
        let storage = NetworkTasksStorage()
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let retrieved = await storage.task(for: request)
        
        #expect(retrieved == nil)
    }
    
    @Test func removeTask() async throws {
        let storage = NetworkTasksStorage()
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let task = MockTask(request: request)
        
        await storage.add(task, for: task.request)
        await storage.remove(task.request)
        
        let retrieved = await storage.task(for: task.request)
        #expect(retrieved == nil)
    }
    
    @Test func cancelAllTasks() async throws {
        let storage = NetworkTasksStorage()
        let urls = [
            URL(string: "https://example.com/1")!,
            URL(string: "https://example.com/2")!,
            URL(string: "https://example.com/3")!
        ]
        
        var tasks = [MockTask]()
        
        for url in urls {
            let task = MockTask(request: URLRequest(url: url))
            tasks.append(task)
            await storage.add(task, for: task.request)
        }
        
        await storage.cancelAll()
        
        for task in tasks {
            let isCancelled = await task.isCancelled
            #expect(isCancelled)
        }
    }
    
    @Test func cancelAllTasksRemovesTasks() async throws {
        let storage = NetworkTasksStorage()
        let urls = [
            URL(string: "https://example.com/1")!,
            URL(string: "https://example.com/2")!,
            URL(string: "https://example.com/3")!
        ]
        
        var tasks = [MockTask]()
        
        for url in urls {
            let task = MockTask(request: URLRequest(url: url))
            tasks.append(task)
            await storage.add(task, for: task.request)
        }
        
        await storage.cancelAll()
        
        for task in tasks {
            let retrieved = await storage.task(for: task.request)
            #expect(retrieved == nil)
        }
    }
}
