//
//  ClientCommand.swift
//
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

//@NetworkActor
public protocol ClientCommand {
    typealias Context = ClientCommandContext
    func execute(request: some Request, with context: Context) async -> Context
    mutating func accept(configurations: NetworkingConfigurations)
}

extension ClientCommand {
    public mutating func accept(configurations: NetworkingConfigurations) { }
}
