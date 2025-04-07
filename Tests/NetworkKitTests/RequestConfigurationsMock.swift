//
//  RequestConfigurationsMock.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
@testable import NetworkKit

extension ConfigurationValues {
    static let mock: ConfigurationValues = {
        var values = ConfigurationValues()
        values.url = URL(string: "example.com")
        return values
    }()
}
