//
//  RequestComponent.swift
//
//
//  Created by Joe Maghzal on 30/05/2024.
//

import Foundation

public protocol RequestComponent: RequestModifier {
    func encoding(into request: URLRequest) throws -> URLRequest
}

//MARK: - RequestModifier
extension RequestComponent {
    public func modified(request: URLRequest) throws -> URLRequest {
        return try encoding(into: request)
    }
}
