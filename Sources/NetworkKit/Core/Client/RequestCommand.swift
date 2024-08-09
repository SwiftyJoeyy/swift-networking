//
//  RequestCommand.swift
//
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

public struct RequestCommand: NetworkingConfigurable {
    public var configurations: NetworkingConfigurations
    public var sessionConfiguration: URLSessionConfiguration
    
    private let session: URLSession
    
    public init() {
        self.configurations = .default
        self.sessionConfiguration = .default
        self.session = URLSession(configuration: sessionConfiguration)
    }
}

//MARK: - ClientCommand
extension RequestCommand: ClientCommand {
    public func execute(
        request: some Request,
        with context: Context
    ) async -> Context {
        var resultContext = await requestResult(for: request, with: context)
        
        resultContext = await configurations.statusValidator.execute(
            request: request,
            with: resultContext
        )
        resultContext = await configurations.retryPolicy.execute(
            request: request,
            with: resultContext
        )
        
        return resultContext
    }
    
    public mutating func accept(configurations: NetworkingConfigurations) {
        configurations.updated.forEach { item in
            switch item {
                case .baseURL:
                    self.configurations.baseURL = configurations.baseURL
                case .jsonDecoder:
                    self.configurations.jsonDecoder = configurations.jsonDecoder
                case .retryPolicy:
                    self.configurations.retryPolicy = configurations.retryPolicy
                case .statusValidator:
                    self.configurations.statusValidator = configurations.statusValidator
            }
        }
    }
}

//MARK: - Private Functions
extension RequestCommand {
    private func requestResult(for request: some Request, with context: Context) async -> Context {
        do {
            let id = UUID()
            let urlRequest = try request._urlRequest(configurations.baseURL)
            NetworkLogger.log(request: urlRequest, id: id)
            
            let result = await context.task.execute(
                for: urlRequest,
                session: session
            )
            NetworkLogger.log(result: result, id: id)
            
            let resultContext = context.with(
                result: result.result,
                statusCode: result.statusCode
            )
            return resultContext
        }catch {
            return context.with(result: .failure(error))
        }
    }
}
