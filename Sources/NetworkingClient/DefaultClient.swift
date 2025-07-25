//
//  DefaultClient.swift
//  Networking
//
//  Created by Joe Maghzal on 25/07/2025.
//

import Foundation

/// The default networking client provided by the framework.
///
/// `DefaultClient` offers a preconfigured session with sensible settings for most apps,
/// including standard timeouts, automatic retry for transient errors, and HTTP status validation.
///
/// Use this client when you don’t need advanced customization or want a quick start.
///
/// You can override any part of the session configuration if needed.
@Client public struct DefaultClient {
    /// The default session used by the client.
    public var session: Session {
        Session {
            URLSessionConfiguration.default
                .timeoutIntervalForRequest(60)
                .timeoutIntervalForResource(120)
                .requestCachePolicy(.useProtocolCachePolicy)
        }.retry(using: DefaultRetryInterceptor())
        .validate(using: DefaultStatusValidator())
    }
}

public enum Networking {
    /// The default networking client for simple bootstrapping.
    public static let client = DefaultClient()
}
