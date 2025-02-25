//
//  FormDataBoundaryFactory.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

extension FormData {
    internal enum BoundaryFactory {
        private static let crlf = "\r\n"
        
        internal enum BoundaryType {
            case first, encapsulated, last
        }
    }
}

// MARK: - Functions
extension FormData.BoundaryFactory {
    internal static func makeRandom() -> String {
        let uuid = UUID().uuidString
        return "network.kit.boundary.\(uuid)"
    }
    
    internal static func make(for type: BoundaryType, boundary: String) -> Data {
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
    
    internal static func make(for headers: [String: String]) -> Data {
        var header = headers.reduce(into: "") { partialResult, item in
            partialResult += "\(item.key):\(item.value)\(crlf)"
        }
        header += crlf
        return Data(header.utf8)
    }
}
