//
//  FormDataBody.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation
import UniformTypeIdentifiers

public struct FormDataBody {
    private let content: FormDataContent
}

//MARK: - Initializers
extension FormDataBody {
    public init(
        _ key: String,
        data: Data,
        fileName: String? = nil,
        mimeType: UTType? = nil
    ) {
        self.content = DataFormDataContent(
            key,
            data: data,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    public init(
        _ key: String,
        fileURL: URL,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        self.content = FileFormDataContent(
            key,
            fileURL: fileURL,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager
        )
    }
    
    public init(
        _ key: String,
        filePath: String,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        self.content = FileFormDataContent(
            key,
            filePath: filePath,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager
        )
    }
}

//MARK: - FormDataContent
extension FormDataBody: FormDataContent {
    public var key: String {
        return content.key
    }

    public func stream() throws -> InputStream {
        return try content.stream()
    }
    
    public func contentSize() -> UInt64? {
        return content.contentSize()
    }
    
    public func headers() -> [RequestHeader] {
        return content.headers()
    }
}
