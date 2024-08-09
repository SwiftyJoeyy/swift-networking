//
//  NKError.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

public enum NKError: Error {
    case missingRequestURL
    case invalidRequestURL
    case sessionError(Error)
    case dataDecodingFailed(data: Data, error: Error)
    case cancelled
    case emptyResult
    case emptyData
    case unacceptableStatusCode(ResponseStatus)
    case missingContentType
    case invalidRequestValidation
    case unexpectedResponse(
        expected: RequestResultType.ResultType,
        actual: RequestResultType.ResultType
    )
}
