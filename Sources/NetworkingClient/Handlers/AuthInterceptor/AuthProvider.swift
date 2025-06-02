//
//  AuthProvider.swift
//  Networking
//
//  Created by Joe Maghzal on 31/05/2025.
//

import Foundation
import NetworkingCore

public protocol AuthProvider: Sendable {
    associatedtype Credential: RequestModifier
    var credential: Self.Credential {get}
    
    func refresh(with session: Session) async throws
    func requiresRefresh() -> Bool
}
