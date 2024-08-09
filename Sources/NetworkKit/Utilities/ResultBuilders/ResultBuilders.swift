//
//  ParametersBuilder.swift
//  
//
//  Created by Joe Maghzal on 30/05/2024.
//

import Foundation

public typealias ParametersBuilder = AnyResultBuilder<RequestParametersCollection>

public typealias RequestModifiersBuilder = AnyResultBuilder<RequestModifier>

public typealias RequestComponentsBuilder = AnyResultBuilder<RequestComponent>

public typealias HeadersBuilder = AnyResultBuilder<RequestHeadersCollection>

public typealias PathsBuilder = AnyResultBuilder<RequestURLPath>

public typealias FormDataContentBuilder = AnyResultBuilder<FormDataContent>
