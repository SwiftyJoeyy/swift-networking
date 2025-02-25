//
//  JSONData.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct JSONData {
    private var data: Data?
    
    public init(data: Data?) {
        self.data = data
    }
}

// MARK: - JSONEncodable
extension JSONData: JSONEncodable {
    public func encoded() throws -> Data? {
        return data
    }
}
