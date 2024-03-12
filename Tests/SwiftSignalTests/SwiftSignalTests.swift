/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

import XCTest
@testable import SwiftSignal

final class SwiftSignalTests: XCTestCase {
    func testReadWrite() {
        let signal = Signal(initialValue: 1)
        
        var runCount = 0
        let effect = createEffect {
            print(signal())
            runCount += 1
            return nil
        }
        
        XCTAssertEqual(runCount, 1)
        
        signal.write(2)
        XCTAssertEqual(runCount, 2)
        
        // Effect won't run if the new value of its dependency is the
        // same as the previous value.
        signal.write(2)
        XCTAssertEqual(runCount, 2)
        
        effect()
        
        signal.write(3)
        XCTAssertEqual(runCount, 2)
        XCTAssertEqual(signal(), 3)
    }
    
    func testComputed() {
        let signalA = Signal(initialValue: false)
        let signalB = Signal(initialValue: "Alice")
        
        var runCount = 0
        let greeting = createComputed {
            runCount += 1
            
            if signalA.read() {
                return "Goodbye"
            }
            
            return "Hello, \(signalB())"
        }
        
        XCTAssertEqual(greeting(), "Hello, Alice")
        XCTAssertEqual(runCount, 1)
        
        // Computation won't re-run if dependencies are not changed.
        _ = greeting()
        XCTAssertEqual(runCount, 1)
        
        signalB.write("Bob")
        XCTAssertEqual(greeting(), "Hello, Bob")
        XCTAssertEqual(runCount, 2)
        
        signalA.write(true)
        XCTAssertEqual(greeting(), "Goodbye")
        XCTAssertEqual(runCount, 3)
        
        // Dependencies can be dynamic.
        signalB.write("John")
        XCTAssertEqual(greeting(), "Goodbye")
        XCTAssertEqual(runCount, 3)
    }
    
    func testEffectCleanup() {
        let signal = Signal(initialValue: 1)
        
        var runCount = 0
        var cleanupCount = 0
        let effect = createEffect {
            print(signal())
            runCount += 1
            return {
                cleanupCount += 1
            }
        }
        
        XCTAssertEqual(runCount, 1)
        XCTAssertEqual(cleanupCount, 0)
        
        signal.update { $0 + 1 }
        XCTAssertEqual(runCount, 2)
        XCTAssertEqual(cleanupCount, 1)
        
        effect()
        XCTAssertEqual(runCount, 2)
        XCTAssertEqual(cleanupCount, 2)
    }
    
    func testComplexUseCase() {
        let radius = Signal(initialValue: 42.0)
        let content = Signal(initialValue: "Signal rocks")
        let area = createComputed {
            return pow(radius(), 2)
        }
        let isLarge = createComputed {
            return area() > 1000
        }
        let prompt = createComputed {
            if isLarge() {
                return content()
            }
            return "..."
        }
        
        var expectedPrompt = "Signal rocks"
        var runCount = 0
        let effect = createEffect {
            runCount += 1
            XCTAssertEqual(prompt(), expectedPrompt)
            return nil
        }
        
        XCTAssertEqual(runCount, 1)
        
        expectedPrompt = "Signal everywhere"
        content.write("Signal everywhere")
        XCTAssertEqual(runCount, 2)
        
        expectedPrompt = "..."
        radius.write(10)
        XCTAssertEqual(runCount, 3)
        
        content.write("Reactivity is awesome")
        XCTAssertEqual(runCount, 3)
        
        expectedPrompt = "Reactivity is awesome"
        radius.write(100)
        XCTAssertEqual(runCount, 4)
        
        effect()
        
        radius.write(10)
        XCTAssertEqual(runCount, 4)
        XCTAssertEqual(area(), 100)
    }
}
