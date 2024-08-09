//
//  NetworkingClient.swift
//
//
//  Created by Joe Maghzal on 15/06/2024.
//

import Foundation

//@NetworkActor
public protocol NetworkingClient {
    var aggregatedCommand: ClientCommand! {get set}
    @ClientCommandBuilder var command: ClientCommand {get}
}
