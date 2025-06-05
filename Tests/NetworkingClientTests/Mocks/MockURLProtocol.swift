//
//  MockURLProtocol.swift
//  Networking
//
//  Created by Joe Maghzal on 6/2/25.
//

import Foundation
@testable import NetworkingClient

actor MockURLHandler {
    static let shared = MockURLHandler()
    var results = [String: (UInt64?, Result<(Data, ResponseStatus), any Error>)]()
    var executedRequests = [String: URLRequest]()
    
    func setResult(_ result: (UInt64?, Result<(Data, ResponseStatus), any Error>), for id: String) {
        results[id] = result
    }
    
    func appendRequest(_ request: URLRequest, for id: String) {
        executedRequests[id] = request
    }
}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    static func setResult(
        _ result: (UInt64?, Result<(Data, ResponseStatus), any Error>),
        for id: String
    ) async {
        await MockURLHandler.shared.setResult(result, for: id)
    }
    static func setResult(
        _ result: Result<(Data, ResponseStatus), any Error>,
        for id: String
    ) async {
        await MockURLHandler.shared.setResult((nil, result), for: id)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        Task {
            guard let id = request.value(forHTTPHeaderField: "test-id"),
                  let result = await MockURLHandler.shared.results[id]
            else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            await MockURLHandler.shared.appendRequest(request, for: id)
            
            if let delay = result.0 {
                try await Task.sleep(nanoseconds: delay)
            }
            switch result.1 {
            case .success(let data):
                client?.urlProtocol(self, didLoad: data.0)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: data.1.rawValue,
                    httpVersion: nil,
                    headerFields: nil
                )!
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .allowed
                )
            case .failure(let error):
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() { }
}

enum MockURLError: Error, Equatable {
    case errorMock
}
