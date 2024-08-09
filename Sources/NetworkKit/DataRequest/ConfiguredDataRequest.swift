//
//  File.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public typealias DataRequest = ConfiguredRequest<Data>

extension DataRequest {
    public func decode<Model: Decodable>(as type: Model.Type) -> DecodedRequestDecorator<Self, Model> {
        return DecodedRequestDecorator<Self, Model>(self)
    }
}

public struct ConfiguredDataRequest<Req: Request> {
    public let request: Req
    public var configurations = NetworkingConfigurations.default
    
    internal var context: ClientCommandContext
    let command: ClientCommand
}

//MARK: - ConfiguredRequest
extension ConfiguredDataRequest: ConfiguredRequest {
    public func response() async -> Result<Data, Error> {
        var configuredCommand = command
        configuredCommand.accept(configurations: configurations)
        
        let result = await configuredCommand.execute(request: request, with: context)
        
        guard result.state != .stop else {
            return .failure(NKError.cancelled)
        }
        guard let result = result.result else {
            return .failure(NKError.cancelled)
        }
        return result.flatMap { response in
            guard let data = response.data else {
                if response.url != nil {
                    return .failure(NKError.unexpectedResponse(expected: .data, actual: .url))
                }else {
                    return .failure(NKError.emptyData)
                }
            }
            return .success(data)
        }
    }
}
