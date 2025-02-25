//
//  FormData.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public struct FormData {
    private let boundary: String
    private let bufferSize: Int?
    private let inputs: [any FormDataItem]
}

// MARK: - Initializer
extension FormData {
    public init(
        boundary: String? = nil,
        bufferSize: Int? = nil,
        @FormDataItemBuilder _ inputs: () -> [any FormDataItem]
    ) {
        self.boundary = boundary ?? BoundaryFactory.makeRandom()
        self.bufferSize = bufferSize
        self.inputs = inputs()
    }
}

// MARK: - RequestBody
extension FormData: RequestBody {
    public var contentType: ContentType? {
        return ContentType(.multipartFormData(boundary: boundary))
    }
    public func body() throws -> Data? {
        var data = Data()
        
        let firstBoundary = BoundaryFactory.make(for: .first, boundary: boundary)
        data.append(firstBoundary)
        
        let encapsulatedBoundary = BoundaryFactory.make(for: .encapsulated, boundary: boundary)
        for input in inputs {
            let inputData = try input.data()
            data.append(encapsulatedBoundary)
            let headerData = BoundaryFactory.make(for: input.headers.headers)
            data.append(headerData)
            data.append(inputData)
        }
        
        let lastBoundary = BoundaryFactory.make(for: .last, boundary: boundary)
        data.append(lastBoundary)
        
        return data
    }
}
