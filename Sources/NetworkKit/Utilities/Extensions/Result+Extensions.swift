//
//  Result+Extensions.swift
//  
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

extension Result {
    var error: Error? {
        switch self {
            case .success:
                return nil
            case .failure(let error):
                return error
        }
    }
}
