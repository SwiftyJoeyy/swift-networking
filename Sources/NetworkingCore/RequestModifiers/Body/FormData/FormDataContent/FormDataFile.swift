//
//  FormDataFile.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// A form-data item containing a file, used in multipart requests.
@frozen public struct FormDataFile: Equatable, Hashable {
    
    /// The key associated with the form-data item.
    public let key: String
    
    /// The URL of the file to be included in the form-data.
    private let fileURL: URL
    
    /// The optional file name to be used in the request.
    private let fileName: String?
    
    /// The MIME type of the file, if specified.
    private let mimeType: MimeType?
    
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
        mimeType: MimeType? = nil,
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
        mimeType: MimeType? = nil,
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
        if let mimeType = info.mimeType {
#if canImport(UniformTypeIdentifiers)
            ContentType(.mime(mimeType))
#else
            ContentType(.custom(mimeType))
#endif
        }
    }
    
    /// Reads and encodes the file content into ``Data``.
    ///
    /// - Returns: The encoded file data.
    public func data(
        _ configurations: borrowing ConfigurationValues
    ) throws(NetworkingError) -> Data? {
        try checkFileURLValidity()
        try checkFileReachability()
        
        guard let inputStream = InputStream(url: fileURL) else {
            throw .file(.failedStreamCreation(fileURL))
        }
        
        inputStream.open()
        defer {
            inputStream.close()
        }
        
        let bufferSize = configurations.bufferSize
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while inputStream.hasBytesAvailable {
            if let error = inputStream.streamError {
                throw .file(.readingStreamFailed(error: error))
            }
            let bytes = inputStream.read(&buffer, maxLength: bufferSize)
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
    private func fileInfo() -> (name: String?, mimeType: MimeType?) {
        let name = fileName ?? fileURL.lastPathComponent
        
        var fileMimeType = mimeType
#if canImport(UniformTypeIdentifiers)
        if fileMimeType == nil {
            
            let fileExtension = fileURL.pathExtension
            fileMimeType = UTType(filenameExtension: fileExtension)
        }
#endif
        
        return (name: name, mimeType: fileMimeType)
    }
    
    /// Validates whether the file URL is a valid local file path.
    private func checkFileURLValidity() throws(NetworkingError) {
        guard fileURL.isFileURL else {
            throw .file(.invalidFileURL(fileURL))
        }
        
        var directory: ObjCBool = false
        let fileExists = FileManager.default.fileExists(
            atPath: fileURL.path,
            isDirectory: &directory
        )
        
        guard fileExists else {
            throw .file(.fileDoesNotExist(fileURL))
        }
        if directory.boolValue {
            throw .file(.urlIsDirectory(fileURL))
        }
    }
    
    /// Checks if the file at the given URL is reachable and accessible.
    private func checkFileReachability() throws(NetworkingError) {
        do {
            let reachableFile = try fileURL.checkPromisedItemIsReachable()
            guard !reachableFile else {return}
            throw NetworkingError.file(.unreachableFile(fileURL))
        }catch {
            throw .file(
                .failedFileReachabilityCheck(url: fileURL, error: error)
            )
        }
    }
}

// MARK: - CustomStringConvertible
extension FormDataFile: CustomStringConvertible {
    public var description: String {
        return """
        FormDataFile = {
          key = \(key),
          fileName = \(fileName ?? "nil"),
          fileURL = \(fileURL),
          mimeType = \(mimeType?.description ?? "nil"),
          headers = \(headers.headers)
        }
        """
    }
}
