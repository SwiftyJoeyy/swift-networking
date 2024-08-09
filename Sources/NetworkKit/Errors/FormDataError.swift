//
//  FormDataError.swift
//  
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

extension NKError {
    public enum FormDataError: Error {
        case invalidFileURL(URL)
        case fileDoesNotExist(URL)
        case URLIsDirectory(URL)
        case unreachableFile(URL)
        case failedFileReachabilityCheck(url: URL, error: Error)
        case failedStreamCreation(URL)
        case readingStreamFailed(error: Error)
    }
}
