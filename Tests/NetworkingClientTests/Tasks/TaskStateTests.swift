//
//  TaskStateTests.swift
//  Networking
//
//  Created by Joe Maghzal on 22/07/2025.
//

import Foundation
import Testing
@testable import NetworkingClient

struct TaskStateTests {
    private func validateTransition(
        from state: TaskState,
        to states: [TaskState],
        canTransition: Bool
    ) {
        for newState in states {
            #expect(state.canTransition(to: newState) == canTransition)
        }
    }
    
    @Test func testValidTransitions() {
        validateTransition(
            from: .created,
            to: [.running, .cancelled],
            canTransition: true
        )
        
        validateTransition(
            from: .running,
            to: [.intercepting, .suspended, .cancelled, .completed],
            canTransition: true
        )
        
        validateTransition(
            from: .intercepting,
            to: [.running, .cancelled, .completed],
            canTransition: true
        )
        
        validateTransition(
            from: .suspended,
            to: [.running, .cancelled],
            canTransition: true
        )
    }
    
    @Test func testInvalidTransitions() {
        validateTransition(
            from: .created,
            to: [.intercepting, .suspended, .completed],
            canTransition: false
        )
        
        validateTransition(
            from: .running,
            to: [.created],
            canTransition: false
        )
        
        validateTransition(
            from: .intercepting,
            to: [.created, .suspended],
            canTransition: false
        )
        
        validateTransition(
            from: .suspended,
            to: [.created, .intercepting, .completed],
            canTransition: false
        )
        
        validateTransition(
            from: .cancelled,
            to: [.created, .running, .intercepting, .suspended, .completed],
            canTransition: false
        )
        
        validateTransition(
            from: .completed,
            to: [.created, .running, .intercepting, .suspended, .cancelled],
            canTransition: false
        )
    }
}
