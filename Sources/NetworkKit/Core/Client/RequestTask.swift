//
//  RequestTask.swift
//
//
//  Created by Joe Maghzal on 05/06/2024.
//

import Foundation

public protocol RequestTask {
    func execute(
        for request: URLRequest,
        session: URLSession
    ) async -> RequestResult
}

public struct RequestResult {
    let result: Result<RequestResultType, Error>
    let statusCode: ResponseStatus?
    
    init(
        _ result: Result<RequestResultType, Error>, 
        statusCode: ResponseStatus? = nil
    ) {
        self.result = result
        self.statusCode = statusCode
    }
}

public enum RequestResultType {
    case url(URL)
    case data(Data)
}

extension RequestResultType {
    public var data: Data? {
        switch self {
            case .data(let data):
                return data
            default:
                return nil
        }
    }
    
    public var url: URL? {
        switch self {
            case .url(let url):
                return url
            default:
                return nil
        }
    }
    
    public var type: ResultType {
        switch self {
            case .url:
                return .url
            case .data:
                return .data
        }
    }
}

extension RequestResultType {
    public enum ResultType: String, Equatable, Hashable {
        case url
        case data
    }
}
