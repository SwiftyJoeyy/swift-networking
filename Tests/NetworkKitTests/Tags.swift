//
//  Tags.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation
import Testing

extension Tag {
    @Tag internal static var headers: Self
    @Tag internal static var parameters: Self
    @Tag internal static var body: Self
    @Tag internal static var request: Self
    @Tag internal static var path: Self
    @Tag internal static var configurations: Self
}
