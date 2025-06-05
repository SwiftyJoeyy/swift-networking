//
//  DataTaskTests.swift
//  Networking
//
//  Created by Joe Maghzal on 6/4/25.
//

import Foundation
import Testing
@testable import NetworkingClient
@testable import NetworkingCore

@Suite(.tags(.tasks))
struct DataTaskTests {
// MARK: - Properties
    private let session = Session {
        var configs = URLSessionConfiguration.ephemeral
        configs.protocolClasses = [MockURLProtocol.self]
        return configs
    }
    
// MARK: - Tests
    @Test func executingDataTaskReturnsDataAndResponseOnSuccess() async throws {
        let requestID = "data-task-success"
        let request = TestRequest()
            .testID(requestID)
        
        let string = "Hello, this is a data test."
        let expectedStatus = ResponseStatus.ok
        await MockURLProtocol.setResult(
            .success((string.data(using: .utf8)!, expectedStatus)),
            for: requestID
        )
        
        let urlRequest = try request._makeURLRequest(with: session.configurations)
        let response = try await session
            .dataTask(request)
            ._execute(urlRequest, session: session)
       
        let decoded = String(data: response.data, encoding: .utf8)
        #expect(decoded == string)
        #expect(response.response.status == expectedStatus)
    }
    
    @Test func dataTaskResponseDecoding() async throws {
        let requestID = "data-task-decoding"
        let request = TestRequest()
            .testID(requestID)
        
        let expectedObject = TestCodable()
        let data = try JSONEncoder().encode(expectedObject)
        await MockURLProtocol.setResult(
            .success((data, .ok)),
            for: requestID
        )
        
        let object = try await session
            .dataTask(request)
            .decode(as: TestCodable.self)
       
        #expect(object == expectedObject)
    }
    
    @Test func dataTaskResponseDecodingWithCustomDecoder() async throws {
        let requestID = "data-task-decoding-with-custom-decoder"
        let request = TestRequest()
            .testID(requestID)
        
        let expectedObject = TestCodable()
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(expectedObject)
        await MockURLProtocol.setResult(
            .success((data, .ok)),
            for: requestID
        )
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let object = try await session
            .dataTask(request)
            .configuration(\.decoder, decoder)
            .decode(as: TestCodable.self)
       
        #expect(object == expectedObject)
    }
    
    @Test func executingDataTaskThrowsErrorOnFailure() async throws {
        let requestID = "data-task-failure"
        let request = TestRequest()
            .testID(requestID)
        
        let expectedError = MockURLError.errorMock
        await MockURLProtocol.setResult(
            .failure(expectedError),
            for: requestID
        )
        
        let urlRequest = try request._makeURLRequest(with: session.configurations)
        
        try await #require(performing: {
            _ = try await session
                .dataTask(request)
                ._execute(urlRequest, session: session)
        }, throws: { error in
            return (error as NSError).domain == (expectedError as NSError).domain
        })
    }
}

extension DataTaskTests {
    struct TestCodable: Codable, Equatable {
        var someId = UUID()
    }
}
