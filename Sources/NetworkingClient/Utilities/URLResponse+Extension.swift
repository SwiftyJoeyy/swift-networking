//
//  URLResponse+Extension.swift
//  Networking
//
//  Created by Joe Maghzal on 2/15/25.
//

import Foundation
import NetworkingCore

extension URLResponse {
    /// The HTTP status of the response, if applicable.
    ///
    /// This property attempts to cast the response as an ``HTTPURLResponse``
    /// and extract the ``statusCode``. It then maps the status code to
    /// a ``ResponseStatus`` enum.
    ///
    /// - Returns: The corresponding ``ResponseStatus``.
    public var status: ResponseStatus? {
        let response = self as? HTTPURLResponse
        return response.flatMap({ResponseStatus(rawValue: $0.statusCode)})
    }
}
