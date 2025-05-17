//
//  ModifiersBuilder.swift
//  Networking
//
//  Created by Joe Maghzal on 03/05/2025.
//

import Foundation

@resultBuilder public struct ModifiersBuilder {
    public static func buildExpression<Modifier: RequestModifier>(
        _ mod: Modifier
    ) -> Modifier {
        return mod
    }
    
    public static func buildBlock() -> EmptyModifier {
        return EmptyModifier()
    }
    
    public static func buildBlock<Modifier: RequestModifier>(
        _ modifier: Modifier
    ) -> Modifier {
        return modifier
    }
}

// MARK: - Conditional Modifiers
extension ModifiersBuilder {
    public static func buildIf<Modifier: RequestModifier>(
        _ modifier: Modifier?
    ) -> _OptionalModifier<Modifier> {
        return _OptionalModifier(storage: modifier)
    }
    
    public static func buildEither<TrueContent: RequestModifier, FalseContent: RequestModifier>(
        first: TrueContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .trueContent(first))
    }
    
    public static func buildEither<TrueContent: RequestModifier, FalseContent: RequestModifier>(
        second: FalseContent
    ) -> _ConditionalModifier<TrueContent, FalseContent> {
        return _ConditionalModifier(storage: .falseContent(second))
    }
    
    public static func buildLimitedAvailability<Modifier: RequestModifier>(
        _ modifier: Modifier
    ) -> Modifier {
        return modifier
    }
}

extension ModifiersBuilder {
    public static func buildBlock<M0: RequestModifier, M1: RequestModifier, M2: RequestModifier, M3: RequestModifier, M4: RequestModifier, M5: RequestModifier, M6: RequestModifier, M7: RequestModifier, M8: RequestModifier, M9: RequestModifier>(
        _ m0: M0, _ m1: M1, _ m2: M2 = EmptyModifier(), _ m3: M3 = EmptyModifier(), _ m4: M4 = EmptyModifier(), _ m5: M5 = EmptyModifier(), _ m6: M6 = EmptyModifier(), _ m7: M7 = EmptyModifier(), _ m8: M8 = EmptyModifier(), _ m9: M9 = EmptyModifier()
    ) -> _TupleModifier<M0, M1, M2, M3, M4, M5, M6, M7, M8, M9> {
        _TupleModifier(m0, m1, m2, m3, m4, m5, m6, m7, m8, m9)
    }
}
