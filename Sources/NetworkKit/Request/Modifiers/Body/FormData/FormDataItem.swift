//
//  FormDataItem.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

public typealias FormDataItemBuilder = AnyResultBuilder<any FormDataItem>

public protocol FormDataItem {
    var key: String {get}
    
    var contentSize: UInt64? {get}
    
    @HeadersBuilder var headers: HeadersGroup {get}
    
    func data() throws -> Data
}
