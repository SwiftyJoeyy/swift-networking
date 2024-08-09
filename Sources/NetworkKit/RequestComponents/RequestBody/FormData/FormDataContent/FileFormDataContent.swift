//
//  FileFormDataContent.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation
import UniformTypeIdentifiers

public struct FileFormDataContent {
    public typealias FactoryError = NKError.FormDataError
    
    public let key: String
    
    private let fileURL: URL
    private let filePath: String
    private let fileName: String?
    private let mimeType: UTType?
    private let fileManager: FileManager
}

//MARK: - Initializers
extension FileFormDataContent {
    public init(
        _ key: String,
        fileURL: URL,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        self.key = key
        self.fileURL = fileURL
        self.filePath = fileURL.path()
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileManager = fileManager
    }
    
    public init(
        _ key: String,
        filePath: String,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        let url =  URL(string: filePath)!
        self.init(key, fileURL: url, fileName: fileName, mimeType: mimeType, fileManager: fileManager)
    }
}

//MARK: - FormDataContent
extension FileFormDataContent: FormDataContent {
    public func stream() throws -> InputStream {
        try checkFileURLValidity()
        
        try checkFileReachability()
        
        guard let stream = InputStream(url: fileURL) else {
            throw FactoryError.failedStreamCreation(fileURL)
        }
        
        return stream
    }
    
    public func contentSize() -> UInt64? {
        let fileAttributes = try? fileManager.attributesOfItem(atPath: filePath)
        let fileSize = fileAttributes?[.size] as? NSNumber
        return fileSize?.uint64Value
    }
    
    public func headers() -> [RequestHeader] {
        let info = fileInfo()
        var headers: [RequestHeader] = [
            ContentDisposition(key, fileName: info.name)
        ]
        if let mimeType = info.mimeType?.preferredMIMEType {
            headers.append(ContentType(mimeType))
        }
        return headers
    }
}

//MARK: - Private Functions
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
        let fileExists = fileManager.fileExists(atPath: filePath, isDirectory: &directory)
        
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
            guard reachableFile else {
                throw FactoryError.unreachableFile(fileURL)
            }
        }catch {
            throw FactoryError.failedFileReachabilityCheck(url: fileURL, error: error)
        }
    }
}
