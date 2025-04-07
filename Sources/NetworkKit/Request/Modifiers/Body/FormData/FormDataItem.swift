//
//  FormDataItem.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Builder used to construct an array of ``FormDataItem``.
public typealias FormDataItemBuilder = AnyResultBuilder<any FormDataItem>

/// Requirements for defining a form-data item used in multipart requests.
public protocol FormDataItem {
    /// The key associated with the form-data item.
    var key: String {get}
    
    /// The size of the content, if known.
    var contentSize: UInt64? {get}
    
    /// The headers associated with the form-data item.
    @HeadersBuilder var headers: HeadersGroup {get}
    
    /// Encodes and returns the form-data item as ``Data``.
    ///
    /// - Returns: The encoded data.
    func data() throws -> Data
}
