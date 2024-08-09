//
//  ConfiguredRequest.swift
//
//
//  Created by Joe Maghzal on 15/06/2024.
//

import Foundation

public protocol ConfiguredRequest<Response>: Request, NetworkingConfigurable {
    associatedtype Response
    
    var configurations: NetworkingConfigurations {get set}
    
    func response() async -> Result<Response, Error>
}
