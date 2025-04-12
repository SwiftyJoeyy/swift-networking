//
//  FormDataError.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension NKError {
    public enum FormDataError: Error {
        case invalidFileURL(URL)
        case fileDoesNotExist(URL)
        case urlIsDirectory(URL)
        case unreachableFile(URL)
        case failedFileReachabilityCheck(url: URL, error: any Error)
        case failedStreamCreation(URL)
        case readingStreamFailed(error: any Error)
    }
}
