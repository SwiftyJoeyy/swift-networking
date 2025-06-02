//
//  MyNewBenchmarkTarget.swift
//  Networking
//
//  Created by Joe Maghzal on 5/29/25.
//

import Benchmark
import Foundation
import Networking

//@Client
//struct MyClient {
//    var command: Session {
//        Session()
//            .url("https://www.google.com")
//            .retryPolicy(.doNotRetry)
//    }
//}

@Request
struct BaseRequest {
    @Header var language = "en"
    @Parameter var data = "12"
    var timeout: TimeInterval = 90
    var request: some Request {
        HTTPRequest(path: "path") {
            ContentType(.applicationJson)
            Header("Custom", value: "value")
        }.timeout(timeout)
        .method(.post)
        .cachePolicy(.reloadIgnoringCacheData)
        .appendingParameter(Parameter("test", value: "benchmark"))
        .additionalHeaders {
            Header("fjfs", value: "tokr")
            Header("Additional", value: "value")
        }.appending("v2")
    }
}


//let client = MyClient()

let benchmarks : @Sendable () -> Void = {

    func defaultCounter() -> Int {
        10
    }
    
    func dummyCounter(_ count: Int) {
        for index in 0 ..< count {
            blackHole(index)
        }
    }
    
    Benchmark("All metrics, full concurrency, async", configuration: .init(metrics: BenchmarkMetric.all)) { benchmark in
        var url = URL(string: "https://example.com")!
        url.append(path: "v2")
        url.append(
            queryItems: [
                URLQueryItem(name: "test", value: "benchmark"),
                URLQueryItem(name: "data", value: "12")
            ]
        )
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 90
        urlRequest.setValue("tokr", forHTTPHeaderField: "fjfs")
        urlRequest.setValue("value", forHTTPHeaderField: "Additional")
        urlRequest.setValue("value", forHTTPHeaderField: "Custom")
        urlRequest.setValue("en", forHTTPHeaderField: "language")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        do {
//            let request = try AnyRequest(BaseRequest())._makeURLRequest()
//        }catch {
//            print(error)
//        }
    }
}
//
//struct ResponseB<T: Decodable>: Decodable {
//    var message: String?
//    var status_code: Int?
//    var errors: Errors?
//    var data: T?
//}
//
//struct Errors: Decodable {
//    var message: [String]?
//    var info: [String]?
//}
//
//extension DataTask {
//    func ttdecode<T: Decodable>(as type: T.Type) async throws -> T {
//        let response = try await response()
//        let decoder = await configurations.decoder
//        let decoded = try decoder.decode(ResponseB<T>.self, from: response.data)
//        if let message = decoded.message {
//            throw NSError(domain: message, code: 100)
//        }
//        if let data = decoded.data {
//            return data
//        }
//        throw NSError(domain: "Emptyy", code: 101)
//    }
//}
