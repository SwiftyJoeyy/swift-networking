//
//  AggregatedCommand.swift
//
//
//  Created by Joe Maghzal on 04/06/2024.
//

import Foundation

internal struct AggregatedCommand {
    private var commands: [ClientCommand]
    
    internal init(commands: [ClientCommand]) {
        self.commands = commands
    }
}

//MARK: - ClientCommand
extension AggregatedCommand: ClientCommand {
    internal func execute(request: some Request, with context: Context) async -> Context {
        var commandContext = context
        for command in commands {
            commandContext = await command.execute(request: request, with: commandContext)
            let state = commandContext.state
            if state == .stop {
                commandContext = commandContext.with(result: .failure(NKError.cancelled))
                return commandContext
            }else if state == .stopAndRetry {
                return await execute(request: request, with: commandContext)
            }
        }
        return commandContext
    }
    
    internal mutating func accept(configurations: NetworkingConfigurations) {
        for index in 0..<commands.count {
            commands[index].accept(configurations: configurations)
        }
    }
}
