//
//  FormDataBody.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import UniformTypeIdentifiers

/// A form-data body that can contain either raw data or a file.
@frozen public struct FormDataBody {
    /// The content of the form-data body.
    private let content: any FormDataItem
}

// MARK: - Initializers
extension FormDataBody {
    /// Creates a new ``FormDataBody`` from raw ``Data``.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - data: The raw data content.
    ///   - fileName: The optional file name for the data.
    ///   - mimeType: The optional MIME type of the data.
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
    
    /// Creates a new ``FormDataBody`` from a file at a given URL.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - fileURL: The URL of the file to include in the form-data.
    ///   - fileName: The optional file name for the file.
    ///   - mimeType: The optional MIME type of the file.
    ///   - fileManager: The ``FileManager`` instance used for file operations.
    ///   - bufferSize: The buffer size for reading large files.
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
    
    /// Creates a new ``FormDataBody`` from a file at a given file path.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - filePath: The file path of the file to include in the form-data.
    ///   - fileName: The optional file name for the file.
    ///   - mimeType: The optional MIME type of the file.
    ///   - fileManager: The ``FileManager`` instance used for file operations.
    ///   - bufferSize: The buffer size for reading large files.
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
    /// The key associated with the form-data item.
    public var key: String {
        return content.key
    }
    
    /// The size of the content in bytes, if available.
    public var contentSize: UInt64? {
        return content.contentSize
    }
    
    /// The headers associated with the form-data item.
    public var headers: HeadersGroup {
        content.headers
    }
    
    /// Encodes the form-data content into ``Data``.
    ///
    /// - Returns: The encoded data.
    public func data() throws -> Data {
        return try content.data()
    }
}
