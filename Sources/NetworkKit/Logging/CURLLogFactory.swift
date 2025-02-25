//
//  CURLLogFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

package enum CURLLogFactory {
    private static let newLine = " \\\n"
    private static let cURL = "curl"
    
    package static func make(for request: URLRequest) -> String {
        let method = "--request \(request.httpMethod ?? "GET")\(newLine)"
        let url = request.url.flatMap({"--url '\($0.absoluteString)'\(newLine)"})
        
        let header = makeHeaders(request.allHTTPHeaderFields)
        let body = makeBody(request.httpBody)
        
        return [cURL, method, url, header, body]
            .compactMap({$0})
            .joined(separator: " ")
    }
    
// MARK: - Private Functions
    private static func makeHeaders(_ fields: [String: Any]?) -> String? {
        let headers = fields?
            .map({"--header '\($0): \($1)'"})
            .joined(separator: "\(newLine) ")
        return headers.map({"\($0)\(newLine)"})
    }
    private static func makeBody(_ body: Data?) -> String? {
        guard let body, !body.isEmpty else {
            return nil
        }
        if let utf8String = String(data: body, encoding: .utf8) {
            return "--data '\(utf8String)'"
        }else {
            let hexString = body
                .map({String(format: "%02X", $0)})
                .joined()
            return #"--data "$(echo '\#(hexString)' | xxd -p -r)"\#(newLine)"#
        }
    }
}
