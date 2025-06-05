//
//  Result+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 6/2/25.
//

import Foundation

extension Result {
    /// The error if the result is a failure.
    internal var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
    
    /// The valiue if the result is a success.
    internal var value: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }
}
