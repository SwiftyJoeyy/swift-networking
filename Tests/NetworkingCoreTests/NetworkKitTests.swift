//
//  NetworkingTests.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Testing
import Foundation
@testable import NetworkingCore

////@Test
//func test() async throws {
//    let client = MyClient()
//    let data = try await client.dataTask(TestingRequest())
//        .decode(with: JSONDecoder())
//        .retryPolicy(.doNotRetry)
//        .decode(as: String.self)
//    print(data)
//}
//
//@Client struct MyClient {
//    var session: Session {
//        Session {
//            URLSessionConfiguration.default
//                .urlCache(.shared)
//                .requestCachePolicy(.returnCacheDataElseLoad)
//                .timeoutIntervalForRequest(90)
//                .timeoutIntervalForResource(90)
//                .httpMaximumConnectionsPerHost(2)
//                .waitForConnectivity(true)
//                .headers {
//                    Header("Key", value: "Value")
//                }
//        }.onRequest { request, task, session in
//            // handle request creation
//            return request
//        }.enableLogs(true)
//        .validate(for: [.accepted, .ok])
//        .retry(limit: 2, for: [.conflict, .badRequest])
//        .baseURL(URL(string: "example.com"))
//        .encode(with: JSONEncoder())
//        .decode(with: JSONDecoder())
//    }
//}
//
//@Request("test-request-id")
//struct TestingRequest {
//    @Header("hi_filed") var test = "test"
//    @Parameter var testing = 1
//    var request: some Request {
//        HTTPRequest(url: "https://www.google.com") {
//            Header("test", value: "value")
//            Parameter("some", values: ["1", "2"])
//            JSON("fwbfw") // optionally here
//        }.body { // JSON, overwrites the one defined in the body
//            JSON("fwbfwejkfrnewkjrewrfw")
//        }.body { // Or Form Data
//            FormData {
//                FormDataBody(
//                    "Image",
//                    data: Data(),
//                    fileName: "image.png",
//                    mimeType: .png
//                )
//                FormDataFile(
//                    "File",
//                    fileURL: URL(filePath: "filePath"),
//                    fileName: "file",
//                    mimeType: .fileURL
//                )
//            }
//        }.method(.get)
//        .timeout(90)
//        .cachePolicy(.reloadIgnoringLocalCacheData)
//        .appending(path: "v1")
//        .additionalHeaders {
//            Header("Header", value: "10")
//            AcceptLanguage("en")
//        }.additionalParameters {
//            Parameter("Item", value: "value")
//        }
//    }
//}
//
//@Request
//struct TestRequest {
//    var timeout: TimeInterval = 90
//    var request: some Request {
//        TestingRequest()
//            .timeout(timeout)
//            .method(.post)
//            .additionalHeaders {
//                Header("Additional", value: "value")
//            }.appending(paths: "v3")
//    }
//}
