//
//  URLResponse+Extension.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation

extension URLResponse {
    public var status: ResponseStatus? {
        let response = self as? HTTPURLResponse
        return response.flatMap({ResponseStatus(rawValue: $0.statusCode)})
    }
}
