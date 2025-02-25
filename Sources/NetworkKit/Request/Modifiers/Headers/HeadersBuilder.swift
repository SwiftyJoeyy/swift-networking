//
//  HeadersBuilder.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

@resultBuilder
public struct HeadersBuilder {
    public static func buildBlock(_ components: (any RequestHeader)...) -> HeadersGroup {
        return buildArray(components)
    }
    public static func buildArray(_ components: [any RequestHeader]) -> HeadersGroup {
        var headers = [String: String]()
        for component in components {
            headers.merge(component.headers) { _, new in
                return new
            }
        }
        return HeadersGroup(headers)
    }
    public static func buildLimitedAvailability(_ component: some RequestHeader) -> HeadersGroup {
        return HeadersGroup(component.headers)
    }
    public static func buildExpression(_ expression: some RequestHeader) -> HeadersGroup {
        return HeadersGroup(expression.headers)
    }
    public static func buildOptional(_ component: (any RequestHeader)?) -> HeadersGroup {
        return HeadersGroup(component?.headers ?? [:])
    }
    public static func buildEither(first component: some RequestHeader) -> HeadersGroup {
        return HeadersGroup(component.headers)
    }
    public static func buildEither(second component: some RequestHeader) -> HeadersGroup {
        return HeadersGroup(component.headers)
    }
}
