//
//  ParametersRequestModifier.swift
//  
//
//  Created by Joe Maghzal on 08/06/2024.
//

import Foundation

fileprivate struct ParametersRequestModifier {
    private let parametersGroup: ParametersGroup
    
    fileprivate init(_ parametersGroup: ParametersGroup) {
        self.parametersGroup = parametersGroup
    }
}

//MARK: - RequestModifier
extension ParametersRequestModifier: RequestModifier {
    fileprivate func modified(request: URLRequest) throws -> URLRequest {
        return try parametersGroup.encoding(into: request)
    }
}

//MARK: - Modifier
extension Request {
    public func additionalParameters(
        @ParametersBuilder _ parameters: () -> [RequestParametersCollection]
    ) -> some Request {
        modifier(ParametersRequestModifier(ParametersGroup(parameters)))
    }
}
