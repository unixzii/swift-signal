/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

import SwiftUI
import Combine
import SwiftSignal

/// An observed signal for using in SwiftUI views.
public class ObservedSignal<T: Equatable>: ObservableObject {
    
    public let signal: Signal<T>
    private var watchEffect: DisposeAction!
    
    public let objectWillChange = ObservableObjectPublisher()
    
    public init(signal: Signal<T>) {
        self.signal = signal
        self.watchEffect = createEffect { [unowned self] in
            _ = signal()
            self.objectWillChange.send()
            return nil
        }
    }
    
    public func callAsFunction() -> T {
        return signal()
    }
}

/// An observed computed for using in SwiftUI views.
public class ObservedComputed<T: Equatable>: ObservableObject {
    
    public let computed: ComputedGetter<T>
    private var watchEffect: DisposeAction!
    
    public let objectWillChange = ObservableObjectPublisher()
    
    public init(_ fn: @escaping () -> T) {
        self.computed = createComputed(fn)
        self.watchEffect = createEffect { [unowned self] in
            _ = self.computed()
            self.objectWillChange.send()
            return nil
        }
    }
    
    public func callAsFunction() -> T {
        return computed()
    }
}
