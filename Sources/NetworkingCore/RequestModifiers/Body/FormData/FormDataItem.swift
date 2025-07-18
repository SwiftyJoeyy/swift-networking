//
//  FormDataItem.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// Requirements for defining a form-data item used in multipart requests.
public protocol FormDataItem {
    associatedtype Header: RequestHeader
    
    /// The headers associated with the form-data item.
    @HeadersBuilder var headers: Self.Header {get}
    
    /// Encodes and returns the form-data item as ``Data``.
    ///
    /// - Returns: The encoded data.
    func data(
        _ configurations: borrowing ConfigurationValues
    ) throws(NetworkingError) -> Data?
}
