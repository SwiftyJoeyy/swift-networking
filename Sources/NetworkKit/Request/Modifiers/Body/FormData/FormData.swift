//
//  FormData.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A multipart form-data request body.
@frozen public struct FormData {
    /// The boundary string used for separating form-data parts.
    private let boundary: String
    
    /// The buffer size for reading large files, if applicable.
    private let bufferSize: Int?
    
    /// The form-data items included in the request.
    private let inputs: [any FormDataItem]
}

// MARK: - Initializer
extension FormData {
    /// Creates a new form-data request body.
    ///
    /// - Parameters:
    ///   - boundary: The boundary string (auto-generated if not provided).
    ///   - bufferSize: The buffer size for reading large files.
    ///   - inputs: The form-data items.
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
    /// The content type of the form-data request.
    public var contentType: ContentType? {
        return ContentType(.multipartFormData(boundary: boundary))
    }
    
    /// Encodes the form-data body into ``Data``.
    ///
    /// - Returns: The encoded form-data.
    public func body(
        for configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        var data = Data()
        
        let firstBoundary = BoundaryFactory.makeBoundary(.first, for: boundary)
        data.append(firstBoundary)
        
        let encapsulatedBoundary = BoundaryFactory.makeBoundary(.encapsulated, for: boundary)
        var foundInputData = false
        for input in inputs {
            guard let inputData = try input.data() else {continue}
            foundInputData = true
            data.append(encapsulatedBoundary)
            let headerData = BoundaryFactory.makeHeaders(for: input.headers.headers)
            data.append(headerData)
            data.append(inputData)
        }
        
        guard foundInputData else {
            return nil
        }
        
        let lastBoundary = BoundaryFactory.makeBoundary(.last, for: boundary)
        data.append(lastBoundary)
        
        return data
    }
}
