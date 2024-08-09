//
//  TimeInterval+Extensions.swift
//  
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

extension TimeInterval {
    public var nanoSeconds: UInt64 {
        return UInt64(self) * 1_000_000_000
    }
}
