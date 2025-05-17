//
//  FormDataFile.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import UniformTypeIdentifiers

/// A form-data item containing a file, used in multipart requests.
@frozen public struct FormDataFile: Equatable, Hashable {
    /// The form-data errors.
    public typealias FactoryError = NetworkingError.FormDataError
    
    /// The key associated with the form-data item.
    public let key: String
    
    /// The URL of the file to be included in the form-data.
    private let fileURL: URL
    
    /// The optional file name to be used in the request.
    private let fileName: String?
    
    /// The MIME type of the file, if specified.
    private let mimeType: UTType?
    
    /// The file manager used for file-related operations.
    private let fileManager: FileManager
}

// MARK: - Initializers
extension FormDataFile {
    /// Creates a new ``FormDataFile`` from a file URL.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - fileURL: The URL of the file to be included in the form-data.
    ///   - fileName: The optional file name for the file.
    ///   - mimeType: The optional MIME type of the file.
    ///   - fileManager: The ``FileManager`` used for file operations.
    ///   - bufferSize: The buffer size for reading large files.
    public init(
        _ key: String,
        fileURL: URL,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        self.key = key
        self.fileURL = fileURL
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileManager = fileManager
    }
    
    /// Creates a new ``FormDataFile`` from a file path.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - filePath: The file path of the file to be included.
    ///   - fileName: The optional file name for the file.
    ///   - mimeType: The optional MIME type of the file.
    ///   - fileManager: The ``FileManager`` used for file operations.
    ///   - bufferSize: The buffer size for reading large files.
    @inlinable public init(
        _ key: String,
        filePath: String,
        fileName: String? = nil,
        mimeType: UTType? = nil,
        fileManager: FileManager = .default
    ) {
        self.init(
            key,
            fileURL: URL(string: filePath)!,
            fileName: fileName,
            mimeType: mimeType,
            fileManager: fileManager
        )
    }
}

// MARK: - FormDataItem
extension FormDataFile: FormDataItem {
    /// The headers associated with the form-data item.
    public var headers: some RequestHeader {
        let info = fileInfo()
        ContentDisposition(name: key, fileName: info.name)
        if let mimeType = info.mimeType?.preferredMIMEType {
            ContentType(.custom(mimeType))
        }
    }
    
    /// Reads and encodes the file content into ``Data``.
    ///
    /// - Returns: The encoded file data.
    public func data(
        _ configurations: borrowing ConfigurationValues
    ) throws -> Data? {
        try checkFileURLValidity()
        try checkFileReachability()
        
        guard let inputStream = InputStream(url: fileURL) else {
            throw FactoryError.failedStreamCreation(fileURL)
        }
        
        inputStream.open()
        defer {
            inputStream.close()
        }
        
        let bufferSize = configurations.bufferSize
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while inputStream.hasBytesAvailable {
            let bytes = inputStream.read(&buffer, maxLength: bufferSize)
            
            if let error = inputStream.streamError {
                throw NetworkingError.FormDataError.readingStreamFailed(error: error)
            }
            guard bytes > 0 else {break}
            data.append(buffer, count: bytes)
        }
        
        return data
    }
}

// MARK: - Private Functions
extension FormDataFile {
    /// Retrieves file metadata such as its name and MIME type.
    ///
    /// - Returns: A tuple containing the file name and MIME type.
    private func fileInfo() -> (name: String?, mimeType: UTType?) {
        let name = fileName ?? fileURL.lastPathComponent
        
        var fileMimeType = mimeType
        if fileMimeType == nil {
            let fileExtension = fileURL.pathExtension
            fileMimeType = UTType(filenameExtension: fileExtension)
        }
        
        return (name: name, mimeType: fileMimeType)
    }
    
    /// Validates whether the file URL is a valid local file path.
    private func checkFileURLValidity() throws {
        guard fileURL.isFileURL else {
            throw FactoryError.invalidFileURL(fileURL)
        }
        
        var directory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(
            atPath: fileURL.path,
            isDirectory: &directory
        )
        
        guard fileExists else {
            throw FactoryError.fileDoesNotExist(fileURL)
        }
        if directory.boolValue {
            throw FactoryError.urlIsDirectory(fileURL)
        }
    }
    
    /// Checks if the file at the given URL is reachable and accessible.
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

// MARK: - CustomStringConvertible
extension FormDataFile: CustomStringConvertible {
    public var description: String {
        return """
        FormDataFile = {
          key = \(key),
          fileName = \(String(describing: fileName)),
          fileURL = \(fileURL),
          mimeType = \(String(describing: mimeType)),
          headers = \(headers)
        }
        """
    }
}
