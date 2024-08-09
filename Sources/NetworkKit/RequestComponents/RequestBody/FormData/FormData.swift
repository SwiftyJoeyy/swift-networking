//
//  FormData.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public protocol FormDataContent {
    var key: String {get}
    
    func stream() throws -> InputStream
    
    func contentSize() -> UInt64?
    
    func headers() -> [RequestHeader]
}

public struct FormData {
    private let boundary: String
    private let bufferSize: Int
    private let inputs: [FormDataContent]
}

//MARK: - Initializer
extension FormData {
    public init(
        boundary: String? = nil,
        bufferSize: Int = 1024,
        @FormDataContentBuilder _ inputs: () -> [FormDataContent]
    ) {
        self.boundary = boundary ?? BoundaryFactory.makeRandom()
        self.bufferSize = bufferSize
        self.inputs = inputs()
    }
}

//MARK: - RequestBody
extension FormData: RequestBody {
    public var contentType: ContentType {
        return ContentType(.multipartFormData(boundary: boundary))
    }
    public func body() throws -> Data? {
        var data = Data()
        
        let firstBoundary = BoundaryFactory.make(for: .first, boundary: boundary)
        data.append(firstBoundary)
        
        let encapsulatedBoundary = BoundaryFactory.make(for: .encapsulated, boundary: boundary)
        for input in inputs {
            let inputData = try encoding(input)
            data.append(encapsulatedBoundary)
            let headerData = BoundaryFactory.make(for: input.headers())
            data.append(headerData)
            data.append(inputData)
        }
        
        let lastBoundary = BoundaryFactory.make(for: .last, boundary: boundary)
        data.append(lastBoundary)
        
        return data
    }
}

//MARK: - Private Functions
extension FormData {
    private func encoding(_ input: FormDataContent) throws -> Data {
        let inputStream = try input.stream()
        inputStream.open()
        defer {
            inputStream.close()
        }
        
        var data = Data()
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            let bytes = inputStream.read(&buffer, maxLength: bufferSize)
            
            if let error = inputStream.streamError {
                throw NKError.FormDataError.readingStreamFailed(error: error)
            }
            guard bytes > 0 else {
                break
            }
            data.append(buffer, count: bytes)
        }
        
        return data
    }
}
