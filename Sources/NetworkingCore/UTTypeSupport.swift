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
public typealias MimeType = UTType
#else
public typealias MimeType = String
#endif
