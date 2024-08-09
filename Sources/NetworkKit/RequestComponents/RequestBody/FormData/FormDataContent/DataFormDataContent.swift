//
//  DataFormDataContent.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation
import UniformTypeIdentifiers

public struct DataFormDataContent {
    public let key: String
    
    private let data: Data
    private let fileName: String?
    private let mimeType: UTType?
}

//MARK: - Initializers
extension DataFormDataContent {
    public init(
        _ key: String,
        data: Data,
        fileName: String? = nil,
        mimeType: UTType? = nil
    ) {
        self.key = key
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

//MARK: - FormDataContent
extension DataFormDataContent: FormDataContent {
    public func stream() throws -> InputStream {
        return InputStream(data: data)
    }
    
    public func contentSize() -> UInt64? {
        return UInt64(data.count)
    }
    
    public func headers() -> [RequestHeader] {
        var headers: [RequestHeader] = [
            ContentDisposition(key, fileName: fileName)
        ]
        if let mimeType = mimeType?.preferredMIMEType {
            headers.append(ContentType(mimeType))
        }
        return headers
    }
}
