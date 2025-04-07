//
//  FormDataBoundaryFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension FormData {
    /// Factory for generating and handling multipart boundaries.
    internal enum BoundaryFactory {
        /// The carriage return and line feed characters.
        private static let crlf = "\r\n"
        
        /// The type of boundary in the multipart request.
        internal enum BoundaryType {
            /// The first boundary in the request body.
            case first
            
            /// A boundary between two form-data parts.
            case encapsulated
            
            /// The final boundary marking the end of the request body.
            case last
        }
    }
}

// MARK: - Functions
extension FormData.BoundaryFactory {
    /// Generates a random boundary string.
    ///
    /// - Returns: A unique boundary string.
    internal static func makeRandom() -> String {
        let uuid = UUID().uuidString
        return "network.kit.boundary.\(uuid)"
    }
    
    /// Creates a boundary ``Data`` representation based on its type.
    ///
    /// - Parameters:
    ///   - type: The type of boundary.
    ///   - boundary: The boundary string.
    ///
    /// - Returns: A ``Data`` representation of the boundary.
    internal static func makeBoundary(
        _ type: BoundaryType,
        for boundary: String
    ) -> Data {
        let currentBoundary = switch type {
        case .first:
            "--\(boundary)\(crlf)"
        case .encapsulated:
            "\(crlf)--\(boundary)\(crlf)"
        case .last:
            "\(crlf)--\(boundary)--\(crlf)"
        }
        
        return Data(currentBoundary.utf8)
    }
    
    /// Creates a ``Data`` representation of request headers.
    ///
    /// - Parameter headers: A dictionary of headers.
    /// - Returns: A ``Data`` object representing the headers.
    internal static func makeHeaders(for headers: [String: String]) -> Data {
        var header = headers.reduce(into: "") { partialResult, item in
            partialResult += "\(item.key):\(item.value)\(crlf)"
        }
        header += crlf
        return Data(header.utf8)
    }
}
