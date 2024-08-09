////
////  NetworkKitTests.swift
////
////
////  Created by Joe Maghzal on 04/06/2024.
////
//
//import XCTest
//@testable import NetworkKit
//
//final class NetworkKitTests: XCTestCase {
//    func test() async {
//        let client = NetworkClient()
//    
//        let request = TestRequest(contentLanguage: "ar")
//        let data = await client.data(for: request)
//            .retryPolicy(limit: 2, for: .accepted) { error, status in
//                return .doNotRetry
//            }.validate(.ok)
//            .decode(as: String.self)
//            .decoder(JSONDecoder())
//            .response()
//    }
//}
//
//// Simplified request
//let request = #request(.get, path: "path") {
//    Parameter("key", value: "98")
//    AcceptLanguage("en")
//}
//
//@Request
//public struct TestRequest {
//    @Parameter var testingKey = "d"
//    @Header("Content-Language") var contentLanguage: String
//    public var request: some Request {
//        HTTPRequest {
//            Parameter("key", value: "98")
//            AcceptLanguage("en")
//        }.additionalHeaders {
//            Header("hh", value: "hhh")
//        }.timeout(10)
//    }
//}
//
//@Client
//public struct NetworkClient {
//    public var command: ClientCommand {
//        RequestCommand()
//            .url("https://google.com")
//            .retry(limit: 2, for: 500) { error, status in
//                return .retry
//            }.retryPolicy(policy)
//        DefaultRetryingCommand()
//    }
//}
