//
//  CURLLogFactory.swift
//
//
//  Created by Joe Maghzal on 17/06/2024.
//

import Foundation

package enum CURLLogFactory {
    package static func make(for request: URLRequest) -> String {
        let newLine = " \\\n"
        let cURL = "curl"
        let method = "--request \(request.httpMethod ?? "GET")\(newLine)"
        let url = request.url.flatMap({"--url '\($0.absoluteString)'\(newLine)"})
        
        var header = request.allHTTPHeaderFields?
            .map({"--header '\($0): \($1)'"})
            .joined(separator: "\(newLine) ")
        header = header.map({"\($0)\(newLine)"})
        
        var data: String?
        if let httpBody = request.httpBody, !httpBody.isEmpty {
            if let bodyString = String(data: httpBody, encoding: .utf8) {
                data = "--data '\(bodyString)'"
            }else {
                let hexString = httpBody
                    .map({String(format: "%02X", $0)})
                    .joined()
                data = #"--data "$(echo '\#(hexString)' | xxd -p -r)"\(newLine)"#
            }
        }
        
        return [cURL, method, url, header, data]
            .compactMap({$0})
            .joined(separator: " ")
    }
}
