//
//  ParametersBuilder.swift
//  Networking
//
//  Created by Joe Maghzal on 2/17/25.
//

import Foundation

@resultBuilder public struct ParametersBuilder {
    public static func buildExpression<Param: RequestParameter>(
        _ param: Param
    ) -> Param {
        return param
    }
    
    public static func buildBlock() -> EmptyModifier {
        return EmptyModifier()
    }
    
    public static func buildBlock<Param: RequestParameter>(
        _ param: Param
    ) -> Param {
        return param
    }
}

// MARK: - Conditional Modifiers
extension ParametersBuilder {
    public static func buildIf<Param: RequestParameter>(
        _ param: Param?
    ) -> _OptionalModifier<Param> {
        return _OptionalModifier(storage: param)
    }
    
    public static func buildEither<TrueContent: RequestParameter, FalseContent: RequestParameter>(
        first: TrueContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .trueContent(first))
    }
    
    public static func buildEither<TrueContent: RequestParameter, FalseContent: RequestParameter>(
        second: FalseContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .falseContent(second))
    }
    
    public static func buildLimitedAvailability<Param: RequestParameter>(
        _ param: Param
    ) -> Param {
        return param
    }
}

extension ParametersBuilder {
    public static func buildBlock<M0: RequestParameter, M1: RequestParameter, M2: RequestParameter, M3: RequestParameter, M4: RequestParameter, M5: RequestParameter, M6: RequestParameter, M7: RequestParameter, M8: RequestParameter, M9: RequestParameter>(
        _ m0: M0, _ m1: M1, _ m2: M2 = EmptyModifier(), _ m3: M3 = EmptyModifier(), _ m4: M4 = EmptyModifier(), _ m5: M5 = EmptyModifier(), _ m6: M6 = EmptyModifier(), _ m7: M7 = EmptyModifier(), _ m8: M8 = EmptyModifier(), _ m9: M9 = EmptyModifier()
    ) -> _TupleModifier<M0, M1, M2, M3, M4, M5, M6, M7, M8, M9> {
        _TupleModifier(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9)
    }
}
