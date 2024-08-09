//
//  HeadersBuilder.swift
//
//
//  Created by Joe Maghzal on 29/05/2024.
//

import Foundation

@resultBuilder
public struct ClientCommandBuilder {
    public typealias Item = ClientCommand
    
    public static func buildBlock(_ components: Item...) -> Item {
        return buildArray(components)
    }
    public static func buildArray(_ components: [Item]) -> Item {
        return AggregatedCommand(commands: components)
    }
    public static func buildLimitedAvailability(_ component: Item) -> Item {
        return component
    }
    public static func buildExpression(_ expression: Item) -> Item {
        return expression
    }
    public static func buildEither(first component: Item) -> Item {
        return component
    }
    public static func buildEither(second component: Item) -> Item {
        return component
    }
}
