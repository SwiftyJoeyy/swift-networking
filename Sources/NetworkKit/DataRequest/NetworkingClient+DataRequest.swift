//
//  NetworkingClient+DataRequest.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

extension NetworkingClient {
    public func data<T: Request>(for request: T) async -> ConfiguredDataRequest<T> {
        let context = ClientCommandContext.initial(task: DataTask())
        return ConfiguredDataRequest(request: request, context: context, command: command)
    }
}
