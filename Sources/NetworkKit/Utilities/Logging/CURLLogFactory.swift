//
//  CURLLogFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Factory for generating `cURL` command representations of a ``URLRequest``.
package enum CURLLogFactory {
    /// The newline character used for formatting multi-line cURL commands.
    private static let newLine = " \\\n"
    /// The base `cURL` command.
    private static let cURL = "cURL"
    
    /// Creates a `cURL` command representation for a given ``URLRequest``.
    ///
    /// - Parameter request: The ``URLRequest`` to convert into a cURL command.
    /// - Returns: A string containing the equivalent `cURL` command.
    package static func make(for request: borrowing URLRequest) -> String {
        let method = "--request \(request.httpMethod ?? "GET")\(newLine)"
        let url = request.url.flatMap({"--url '\($0.absoluteString)'\(newLine)"})
        
        let header = makeHeaders(request.allHTTPHeaderFields)
        let body = makeBody(request.httpBody)
        
        return [cURL, method, url, header, body]
            .compactMap({$0})
            .joined(separator: " ")
    }
    
// MARK: - Private Functions
    /// Generates the cURL headers from the request's header fields.
    ///
    /// - Parameter fields: A dictionary containing HTTP header fields.
    /// - Returns: A formatted string representing the headers for the cURL command,
    /// or `nil` if no headers exist.
    private static func makeHeaders(_ fields: [String: String]?) -> String? {
        let headers = fields?
            .map({"--header '\($0): \($1)'"})
            .joined(separator: "\(newLine) ")
        return headers.map({"\($0)\(newLine)"})
    }
    
    /// Generates the cURL body from the request's HTTP body data.
    ///
    /// - Parameter body: The HTTP body data.
    /// - Returns: A formatted string representing the body for the cURL command,
    /// or `nil` if the body is empty.
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
