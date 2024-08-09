//
//  File.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public struct DecodedRequestDecorator<Req: DataRequest, Model: Decodable> {
    public let request: Req
    public var configurations: NetworkingConfigurations
    
    internal init(_ request: Req) {
        self.request = request
        self.configurations = request.configurations
    }
}

extension DecodedRequestDecorator: ConfiguredRequest {
    public func response() async -> Result<Model, Error> {
        return await request.response()
            .flatMap { data in
                do {
                    let decoder = configurations.jsonDecoder
                    let decoded = try decoder.decode(Model.self, from: data)
                    return .success(decoded)
                }catch {
                    return .failure(NKError.dataDecodingFailed(data: data, error: error))
                }
            }
    }
}
