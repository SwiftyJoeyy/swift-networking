//
//  ParametersGroup.swift
//
//
//  Created by Joe Maghzal on 5/30/24.
//

import Foundation

public struct ParametersGroup: RequestParametersCollection {
    public let parameters: [URLQueryItem]
    
    public init(@ParametersBuilder _ parameters: () -> [RequestParametersCollection]) {
        self.parameters = parameters().flatMap(\.parameters)
    }
}
