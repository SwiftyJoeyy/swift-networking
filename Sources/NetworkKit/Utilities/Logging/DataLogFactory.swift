//
//  DataLogFactory.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

package enum DataLogFactory {
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
