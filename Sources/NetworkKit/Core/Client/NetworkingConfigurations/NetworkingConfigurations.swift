//
//  File.swift
//  
//
//  Created by Joe Maghzal on 15/06/2024.
//

import Foundation

public protocol NetworkingConfigurable {
    var configurations: NetworkingConfigurations {get set}
}

//MARK: - Decoder Modifiers
extension NetworkingConfigurable {
    public func decoder(_ jsonDecoder: JSONDecoder) -> Self {
        var configurable = self
        configurable.configurations.jsonDecoder = jsonDecoder
        configurable.configurations.updated.insert(.jsonDecoder)
        return configurable
    }
    public func decoder(_ jsonDecoder: () -> JSONDecoder) -> Self {
        return decoder(jsonDecoder())
    }
}

//MARK: - Base URL Modifiers
extension NetworkingConfigurable {
    public func url(_ url: URL?) -> Self {
        var configurable = self
        configurable.configurations.baseURL = url
        configurable.configurations.updated.insert(.baseURL)
        return configurable
    }
    public func url(_ urlString: String) -> Self {
        return url(URL(string: urlString))
    }
}

//MARK: - Retry Policy Modifiers
extension NetworkingConfigurable {
    public func retryPolicy(
        limit: Int,
        for statuses: ResponseStatus...,
        handler: DefaultRetryPolicy.RetryHandler?
    ) -> Self {
        let policy = DefaultRetryPolicy(
            handler: handler,
            maxRetryCount: limit,
            retryableStatuses: statuses
        )
        return retryPolicy(policy)
    }
    public func retryPolicy(_ policy: RetryPolicy) -> Self {
        var configurable = self
        configurable.configurations.retryPolicy = policy
        configurable.configurations.updated.insert(.retryPolicy)
        return configurable
    }
}

//MARK: - Status Validator Modifiers
extension NetworkingConfigurable {
    public func validate(_ statuses: ResponseStatus...) -> Self {
        var configurable = self
        let validator = DefaultStatusValidator(validStatuses: statuses)
        configurable.configurations.statusValidator = validator
        configurable.configurations.updated.insert(.statusValidator)
        return configurable
    }
}

public struct NetworkingConfigurations {
    internal var baseURL: URL?
    internal var jsonDecoder = JSONDecoder()
    internal var retryPolicy: RetryPolicy = DefaultRetryPolicy()
    internal var statusValidator: StatusValidator = DefaultStatusValidator()
    
    internal var updated = Set<Configuration>()
    
    public static var `default`: Self {
        return NetworkingConfigurations()
    }
}

extension NetworkingConfigurations {
    enum Configuration {
        case baseURL
        case jsonDecoder
        case retryPolicy
        case statusValidator
    }
}
