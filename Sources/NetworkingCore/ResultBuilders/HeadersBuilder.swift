//
//  HeadersBuilder.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

@resultBuilder public struct HeadersBuilder {
    public static func buildExpression<Header: RequestHeader>(
        _ header: Header
    ) -> Header {
        return header
    }
    
    public static func buildBlock() -> EmptyModifier {
        return EmptyModifier()
    }
    
    public static func buildBlock<Header: RequestHeader>(
        _ header: Header
    ) -> Header {
        return header
    }
}

// MARK: - Conditional Modifiers
extension HeadersBuilder {
    public static func buildIf<Header: RequestHeader>(
        _ header: Header?
    ) -> _OptionalModifier<Header> {
        return _OptionalModifier(storage: header)
    }
    
    public static func buildEither<TrueContent: RequestHeader, FalseContent: RequestHeader>(
        first: TrueContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .trueContent(first))
    }
    
    public static func buildEither<TrueContent: RequestHeader, FalseContent: RequestHeader>(
        second: FalseContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .falseContent(second))
    }
    
    public static func buildLimitedAvailability<Header: RequestHeader>(
        _ header: Header
    ) -> Header {
        return header
    }
}

extension HeadersBuilder {
    public static func buildBlock<M0: RequestHeader, M1: RequestHeader, M2: RequestHeader, M3: RequestHeader, M4: RequestHeader, M5: RequestHeader, M6: RequestHeader, M7: RequestHeader, M8: RequestHeader, M9: RequestHeader>(
        _ m0: M0, _ m1: M1, _ m2: M2 = EmptyModifier(), _ m3: M3 = EmptyModifier(), _ m4: M4 = EmptyModifier(), _ m5: M5 = EmptyModifier(), _ m6: M6 = EmptyModifier(), _ m7: M7 = EmptyModifier(), _ m8: M8 = EmptyModifier(), _ m9: M9 = EmptyModifier()
    ) -> _TupleModifier<M0, M1, M2, M3, M4, M5, M6, M7, M8, M9> {
        _TupleModifier(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9)
    }
}
