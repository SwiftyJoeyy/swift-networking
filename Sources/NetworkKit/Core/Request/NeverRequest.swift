//
//  NeverRequest.swift
//  
//
//  Created by Joe Maghzal on 29/05/2024.
//

import Foundation

extension Never {
    public struct _Request: Request {
        public var request: Self {
            fatalError("Should not be called directly!!")
        }
    }
}
