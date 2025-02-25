//
//  FormDataBody.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import UniformTypeIdentifiers

public struct FormDataBody {
    private let content: any FormDataItem
}

// MARK: - Initializers
extension FormDataBody {
    public init(
        _ key: String,
        data: Data,
        fileName: String? = nil,
        mimeType: UTType? = nil
    ) {
        self.content = FormDataContent(
            key,
            body: data,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    public init(
        _ key: String,
        fileURL: URL,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default,
        bufferSize: Int = 1024
    ) {
        self.content = FileFormDataContent(
            key,
            fileURL: fileURL,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager,
            bufferSize: bufferSize
        )
    }
    
    public init(
        _ key: String,
        filePath: String,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default,
        bufferSize: Int = 1024
    ) {
        self.content = FileFormDataContent(
            key,
            filePath: filePath,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager,
            bufferSize: bufferSize
        )
    }
}

// MARK: - FormDataItem
extension FormDataBody: FormDataItem {
    public var key: String {
        return content.key
    }
    
    public var contentSize: UInt64? {
        return content.contentSize
    }
    
    public var headers: HeadersGroup {
        content.headers
    }
    
    public func data() throws -> Data {
        return try content.data()
    }
}
