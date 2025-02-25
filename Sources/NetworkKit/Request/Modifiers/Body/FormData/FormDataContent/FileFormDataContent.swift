//
//  FileFormDataContent.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import UniformTypeIdentifiers

public struct FileFormDataContent {
    public typealias FactoryError = NKError.FormDataError
    
    public let key: String
    
    private let fileURL: URL
    private let fileName: String?
    private let mimeType: UTType?
    private let fileManager: FileManager
    private let bufferSize: Int
}

// MARK: - Initializers
extension FileFormDataContent {
    public init(
        _ key: String,
        fileURL: URL,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default,
        bufferSize: Int
    ) {
        self.key = key
        self.fileURL = fileURL
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileManager = fileManager
        self.bufferSize = bufferSize
    }
    
    @inlinable public init(
        _ key: String,
        filePath: String,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default,
        bufferSize: Int
    ) {
        self.init(
            key,
            fileURL: URL(string: filePath)!,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager,
            bufferSize: bufferSize
        )
    }
}

// MARK: - FormDataItem
extension FileFormDataContent: FormDataItem {
    public var contentSize: UInt64? {
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path())
        let fileSize = fileAttributes?[.size] as? NSNumber
        return fileSize?.uint64Value
    }
    
    public var headers: HeadersGroup {
        let info = fileInfo()
        ContentDisposition(key, fileName: info.name)
        if let mimeType = info.mimeType?.preferredMIMEType {
            ContentType(.custom(mimeType))
        }
    }
    
    public func data() throws -> Data {
        try checkFileURLValidity()
        
        try checkFileReachability()
        
        guard let inputStream = InputStream(url: fileURL) else {
            throw FactoryError.failedStreamCreation(fileURL)
        }
        
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

// MARK: - Private Functions
extension FileFormDataContent {
    private func fileInfo() -> (name: String?, mimeType: UTType?) {
        let name = fileName ?? fileURL.lastPathComponent
        
        var fileMimeType = mimeType
        if fileMimeType == nil {
            let fileExtension = fileURL.pathExtension
            fileMimeType = UTType(filenameExtension: fileExtension)
        }
        
        return (name: name, mimeType: fileMimeType)
    }
    private func checkFileURLValidity() throws {
        guard fileURL.isFileURL else {
            throw FactoryError.invalidFileURL(fileURL)
        }
        
        var directory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path(), isDirectory: &directory)
        
        guard fileExists else {
            throw FactoryError.fileDoesNotExist(fileURL)
        }
        if directory.boolValue {
            throw FactoryError.URLIsDirectory(fileURL)
        }
    }
    
    private func checkFileReachability() throws {
        do {
            let reachableFile = try fileURL.checkPromisedItemIsReachable()
            guard !reachableFile else {return}
            throw FactoryError.unreachableFile(fileURL)
        }catch {
            throw FactoryError.failedFileReachabilityCheck(url: fileURL, error: error)
        }
    }
}
