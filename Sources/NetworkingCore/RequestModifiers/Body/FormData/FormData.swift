//
//  FormData.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A multipart form-data request body.
@frozen public struct FormData {
    /// The boundary string used for separating form-data parts.
    private let boundary: String
    
    /// The form-data items included in the request.
    private let inputs: [any FormDataItem]
}

// MARK: - Initializer
extension FormData {
    /// Creates a new form-data request body.
    ///
    /// - Parameters:
    ///   - boundary: The boundary string (auto-generated if not provided).
    ///   - inputs: The form-data items.
    public init(
        boundary: String? = nil,
        @FormDataItemBuilder _ inputs: () -> [any FormDataItem]
    ) {
        self.boundary = boundary ?? BoundaryFactory.makeRandom()
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
            guard let inputData = try input.data(configurations) else {continue}
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

// MARK: - CustomStringConvertible
extension FormData: CustomStringConvertible {
    public var description: String {
        let bodyString = inputs.map({"    " + String(describing: $0)})
        return """
        FormData = {
          contentType = \(contentType?.headers.first?.value ?? "nil"),
          boundary = \(boundary),
          body (\(inputs.count)) = [
        \(bodyString)
          ]
        }
        """
    }
}
