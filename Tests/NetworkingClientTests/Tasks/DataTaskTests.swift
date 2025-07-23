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
    @Test func executingDataTaskReturnsDataOnSuccess() async throws {
        let requestID = "data-task-success"
        let request = TestRequest()
            .testID(requestID)
        
        let string = "Hello, this is a data test."
        await MockURLProtocol.setResult(
            .success((string.data(using: .utf8)!, .ok)),
            for: requestID
        )
        
        let urlRequest = try request._makeURLRequest(with: session.configurations)
        let response = try await session
            .dataTask(request)
            ._execute(urlRequest, session: session)
       
        let decoded = String(data: response.data, encoding: .utf8)
        #expect(decoded == string)
    }
    
    @Test(arguments: [ResponseStatus.accepted, ResponseStatus.badRequest])
    func executingDataTaskReturnsResponseOnSuccess(expectedStatus: ResponseStatus) async throws {
        let requestID = "expect-status\(expectedStatus.rawValue)"
        let request = TestRequest()
            .testID(requestID)
        
        let response = (Data(), expectedStatus)
        await MockURLProtocol.setResult(.success(response), for: requestID)
        
        let status = try await session.dataTask(request)
            .response()
            .1.status
        #expect(status == expectedStatus)
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
    
    @Test func dataTaskResponseDecodingThrowsErrorOnDecodeFailure() async throws {
        let requestID = "data-task-decoding-error"
        let request = TestRequest()
            .testID(requestID)
        
        let data = try JSONEncoder().encode(TestCodable())
        await MockURLProtocol.setResult(
            .success((data, .ok)),
            for: requestID
        )
        
        let networkingError = try await #require(throws: NetworkingError.self) {
            _ = try await session
                .dataTask(request)
                .decode(as: String.self)
        }
        var foundCorrectError = false
        if case NetworkingError.decoding = networkingError {
            foundCorrectError = true
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
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
        
        let networkingError = try await #require(throws: NetworkingError.self) {
            _ = try await session
                .dataTask(request)
                ._execute(urlRequest, session: session)
        }
        var foundCorrectError = false
        if case NetworkingError.custom(let error) = networkingError {
            foundCorrectError = (error as NSError).domain == (expectedError as NSError).domain
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
    }
    
    @Test func urlSessionTaskGetsCancelledWhenCancellingTask() async throws {
        let requestID = "expect-cancellation-error"
        let request = TestRequest()
            .testID(requestID)
        
        await MockURLProtocol.setResult(
            (4_000_000_000, .failure(MockURLError.errorMock)),
            for: requestID
        )
        let task = ErrorExtractingDataTask(request: AnyRequest(request), session: session)
        task._accept(session.configurations)
        
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await task.cancel()
        }
        
        _ = try? await task.response()
        let networkingError = try #require(task.error)
        
        var foundCorrectError = false
        if case NetworkingError.custom(let error) = networkingError,
           let clientError = error as? ClientError,
           case ClientError.urlError(let urlError) = clientError {
            foundCorrectError = urlError.code == .cancelled
        }
        #expect(foundCorrectError, "Found error \(String(describing: networkingError))")
    }
}

extension DataTaskTests {
    struct TestCodable: Codable, Equatable {
        var someId = UUID()
    }
    class ErrorExtractingDataTask: DataTask, @unchecked Sendable {
        var error: NetworkingError?
        
        open override func _execute(
            _ urlRequest: borrowing URLRequest,
            session: Session
        ) async throws(NetworkingError) -> DataResponse {
            do {
                return try await super._execute(urlRequest, session: session)
            }catch {
                self.error = error
                throw error
            }
        }
    }
}
