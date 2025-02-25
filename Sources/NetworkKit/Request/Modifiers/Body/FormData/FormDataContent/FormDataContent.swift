//
//  FormDataContent.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import UniformTypeIdentifiers

public struct FormDataContent {
    public let key: String
    
    private let body: Data
    private let fileName: String?
    private let mimeType: UTType?
}

// MARK: - Initializers
extension FormDataContent {
    public init(
        _ key: String,
        body: Data,
        fileName: String? = nil,
        mimeType: UTType? = nil
    ) {
        self.key = key
        self.body = body
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

// MARK: - FormDataItem
extension FormDataContent: FormDataItem {
    public var contentSize: UInt64? {
        return UInt64(body.count)
    }
    
    public var headers: HeadersGroup {
        ContentDisposition(key, fileName: fileName)
        if let mimeType = mimeType?.preferredMIMEType {
            ContentType(.custom(mimeType))
        }
    }
    
    public func data() throws -> Data {
        return body
    }
}
