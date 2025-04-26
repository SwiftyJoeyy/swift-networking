//
//  RequestConfigurationsMock.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
@testable import NetworkingCore

extension ConfigurationValues {
    static let mock: ConfigurationValues = {
        var values = ConfigurationValues()
        values.baseURL = URL(string: "example.com")
        return values
    }()
}
