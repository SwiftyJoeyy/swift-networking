//
//  FileError.swift
//  Networking
//
//  Created by Joe Maghzal on 12/07/2025.
//

import Foundation

extension NetworkingError {
    public enum FileError: Error, Sendable {
        /// Thrown when the provided file URL is not a valid `file://` URL.
        case invalidFileURL(URL)
        
        /// Thrown when the file at the specified URL does not exist.
        case fileDoesNotExist(URL)
        
        /// Thrown when the specified file URL points to a directory instead of a file.
        case urlIsDirectory(URL)
        
        /// Thrown when the file at the specified URL is not reachable.
        ///
        /// This may occur due to permissions, missing file, or sandbox restrictions.
        case unreachableFile(URL)
        
        /// Thrown when a file reachability check fails with an underlying error.
        ///
        /// - Parameters:
        ///   - url: The URL of the file.
        ///   - error: The error returned by the reachability check.
        case failedFileReachabilityCheck(url: URL, error: any Error)
        
        /// Thrown when an input stream could not be created from the file at the given URL.
        case failedStreamCreation(URL)
        
        /// Thrown when reading from the input stream fails.
        ///
        /// - Parameter error: The error encountered during stream reading.
        case readingStreamFailed(error: any Error)
    }
}

extension NetworkingError.FileError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
            case .invalidFileURL(let url):
                return "The file URL is invalid: \(url.absoluteString)"
            case .fileDoesNotExist(let url):
                return "The file does not exist at path: \(url.path)"
            case .urlIsDirectory(let url):
                return "Expected a file, but found a directory at: \(url.path)"
            case .unreachableFile(let url):
                return "The file at path \(url.path) is not reachable."
            case .failedFileReachabilityCheck(let url, let error):
                return "Failed to check reachability for file at \(url.path). \(error.localizedDescription)"
            case .failedStreamCreation(let url):
                return "Failed to create input stream from file at path: \(url.path)"
            case .readingStreamFailed(let error):
                return "An error occurred while reading from the stream. \(error.localizedDescription)"
        }
    }
}
