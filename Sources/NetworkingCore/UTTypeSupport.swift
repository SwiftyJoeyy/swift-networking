//
//  UTTypeSupport.swift
//  Networking
//
//  Created by Joe Maghzal on 24/05/2025.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if canImport(UniformTypeIdentifiers)
/// Typealias representing a MIME type using ``UTType`` used for content types.
public typealias MimeType = UTType
#else
/// Typealias representing a MIME type using ``String`` used for content types.
public typealias MimeType = String
#endif
