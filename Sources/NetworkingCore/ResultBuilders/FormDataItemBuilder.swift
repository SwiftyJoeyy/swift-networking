//
//  FormDataItemBuilder.swift
//  Networking
//
//  Created by Joe Maghzal on 10/05/2025.
//

import Foundation

@resultBuilder public struct FormDataItemBuilder {
    public typealias Item = any FormDataItem
    public static func buildBlock(_ components: [Item]...) -> [Item] {
        return components.flatMap({$0})
    }
    public static func buildArray(_ components: [[Item]]) -> [Item] {
        return components.flatMap({$0})
    }
    public static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
        return component
    }
    public static func buildExpression(_ expression: Item) -> [Item] {
        return [expression]
    }
    public static func buildExpression(_ expression: [Item]) -> [Item] {
        return expression
    }
    public static func buildOptional(_ component: [Item]?) -> [Item] {
        return component ?? []
    }
    public static func buildEither(first component: [Item]) -> [Item] {
        return component
    }
    public static func buildEither(second component: [Item]) -> [Item] {
        return component
    }
}
