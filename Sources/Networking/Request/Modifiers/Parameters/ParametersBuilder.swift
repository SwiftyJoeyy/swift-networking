//
//  ParametersBuilder.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

@resultBuilder
public struct ParametersBuilder {
    public static func buildBlock(_ components: (any RequestParameter)...) -> ParametersGroup {
        return buildArray(components)
    }
    public static func buildArray(_ components: [any RequestParameter]) -> ParametersGroup {
        let parameters = components.flatMap(\.parameters)
        return ParametersGroup(parameters)
    }
    public static func buildLimitedAvailability(_ component: some RequestParameter) -> ParametersGroup {
        return ParametersGroup(component.parameters)
    }
    public static func buildExpression(_ expression: some RequestParameter) -> ParametersGroup {
        return ParametersGroup(expression.parameters)
    }
    public static func buildOptional(_ component: (any RequestParameter)?) -> ParametersGroup {
        return ParametersGroup(component?.parameters ?? [])
    }
    public static func buildEither(first component: some RequestParameter) -> ParametersGroup {
        return ParametersGroup(component.parameters)
    }
    public static func buildEither(second component: some RequestParameter) -> ParametersGroup {
        return ParametersGroup(component.parameters)
    }
}
