//
//  NetworkKitTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkKit

func test() async throws {
    let client = MyClient()
    let testingRequest = TestingRequest()
        .timeout(10)
    let task = try client.dataTask(testingRequest)
    let data = try await task.response()
}

@Client
struct MyClient {
    var command: RequestCommand {
        RequestCommand()
    }
}

@Request
struct TestingRequest {
    @Header("hi_filed") var test = "test"
    @Parameter var testing = 1
    var request: some Request {
        HTTPRequest(url: "https://www.google.com") {
            JSON("fwbfw")
        }.body {
            JSON("fwbfwejkfrnewkjrewrfw")
        }.method(.get)
    }
}

@Request
struct TestRequest {
    var timeout: TimeInterval = 90
    var request: some Request {
        HTTPRequest(path: "path") {
            ContentType(.applicationJson)
            Header("Custom", value: "value")
            FormData {
                FormDataBody("photo", data: Data(), fileName: "photo.png")
                FormDataBody(
                    "test",
                    filePath: "url",
                    fileName: "test.csv",
                    fileManager: .default,
                    bufferSize: 1024
                )
            }
            JSON("Some custom encodable", encoder: JSONEncoder())
        }.timeout(timeout)
        .method(.post)
        .additionalHeaders {
            Header("Additional", value: "value")
        }.appending(paths: "v2")
        .body {
            JSON("")
        }
    }
}

@Request
struct TestRequest2 {
    var timeout: TimeInterval = 90
    var request: some Request {
        TestRequest()
            .timeout(timeout)
            .method(.post)
            .additionalHeaders {
                Header("Additional", value: "value")
            }.appending(paths: "v3")
    }
}
