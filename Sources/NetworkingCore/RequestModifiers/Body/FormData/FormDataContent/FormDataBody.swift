//
//  FormDataBody.swift
//  Networking
//
//  Created by Joe Maghzal on 2/11/25.
//

import Foundation

/// A single form-data content item used in a multipart request.
@frozen public struct FormDataBody: Equatable, Hashable {
    /// The key associated with the form-data item.
    public let key: String
    
    /// The raw data content of the form-data item.
    private let body: Data?
    
    /// The file name associated with the form-data item, if applicable.
    private let fileName: String?
    
    /// The MIME type of the content, if specified.
    private let mimeType: MimeType?
}

// MARK: - Initializers
extension FormDataBody {
    /// Creates a new ``FormDataBody``.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - body: The raw data content.
    ///   - fileName: The optional file name for the data.
    ///   - mimeType: The optional MIME type of the data.
    public init(
        _ key: String,
        data: Data?,
        fileName: String? = nil,
        mimeType: MimeType? = nil
    ) {
        self.key = key
        self.body = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    /// Creates a new ``FormDataBody``.
    ///
    /// - Parameters:
    ///   - key: The key associated with the form-data item.
    ///   - body: The ``String`` content.
    ///   - fileName: The optional file name for the data.
    ///   - mimeType: The optional MIME type of the data.
    @inlinable public init(
        _ key: String,
        body: String?,
        fileName: String? = nil,
        mimeType: MimeType? = nil
    ) {
        self.init(
            key,
            data: body?.data(using: .utf8),
            fileName: fileName,
            mimeType: mimeType
        )
    }
}

// MARK: - FormDataItem
extension FormDataBody: FormDataItem {
    /// The headers associated with the form-data item.
    public var headers: some RequestHeader {
        ContentDisposition(name: key, fileName: fileName)
        if let mimeType {
#if canImport(UniformTypeIdentifiers)
            ContentType(.mime(mimeType))
#else
            ContentType(.custom(mimeType))
#endif
        }
    }
    
    /// Encodes the form-data content into ``Data``.
    ///
    /// - Returns: The encoded data.
    /// - Throws: A ``NetworkingError`` if request construction fails.
    public func data(
        _ configurations: borrowing ConfigurationValues
    ) throws(NetworkingError) -> Data? {
        return body
    }
}

// MARK: - CustomStringConvertible
extension FormDataBody: CustomStringConvertible {
    public var description: String {
        return """
        FormDataBody = {
          key = \(key),
          fileName = \(fileName ?? "nil"),
          mimeType = \(mimeType?.description ?? "nil")),
          body = \(String(describing: body)),
          headers = \(headers.description)
        }
        """
    }
}
