//
//  DataLogFactory.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Factory for generating human-readable representations of a raw ``Data``.
package enum DataLogFactory {
    /// Converts ``Data`` into a formatted, human-readable string.
    ///
    /// - If the data is valid JSON, it will be pretty-printed.
    /// - If the data is a UTF-8 encoded string, it will be returned as-is.
    /// - If the data is `nil` or cannot be converted, `"Empty Data"` is returned.
    ///
    /// - Parameter data: The ``Data`` to convert.
    /// - Returns: A human-readable string representation of the data.
    package static func make(for data: Data?) -> String {
        guard let data else {
            return "Empty Data"
        }
        let object = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableLeaves
        )
        guard let object else {
            return String(data: data, encoding: .utf8) ?? "Empty Data"
        }
        let objectData = try? JSONSerialization.data(
            withJSONObject: object,
            options: [
                .prettyPrinted,
                .withoutEscapingSlashes
            ]
        )
        guard let objectData,
              let string = String(data: objectData, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "Empty Data"
        }
        return string
    }
}
