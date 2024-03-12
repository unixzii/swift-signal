/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

/// The basic reactive primitive.
///
/// Signals track a single value that changes over time. Signals are the
/// source of truth for other reactive primitives, and have no external
/// dependencies.
public class Signal<T: Equatable>: Source {
    
    private(set) var value: T
    private(set) var observers = Set<AnyObserver>()
    
    /// Creates a signal with an initial value.
    public init(initialValue: T) {
        self.value = initialValue
    }
    
    /// Sets the value of this signal, and updates its dependents.
    public func write(_ newValue: T) {
        if value == newValue {
            return
        }
        
        value = newValue
        
        for observer in observers {
            observer.notify()
        }
    }
    
    /// Updates the value of this signal with its previous value.
    ///
    /// This method works like `write(_:)` expect that the new value is
    /// computed by a closure. Calling this won't mark a dependency for
    /// the caller primitive.
    public func update(_ updater: (T) -> T) {
        let newValue = updater(value)
        write(newValue)
    }
    
    /// Returns the current value of this signal.
    ///
    /// Calling this within a tracking scope causes the caller to depend
    /// on this signal.
    public func read() -> T {
        if let observer = CurrentObserver.value {
            observer.addSource(self)
            observers.insert(observer)
        }
        return value
    }
    
    @inline(__always)
    public func callAsFunction() -> T {
        return read()
    }
    
    func removeObserver(_ observer: AnyObserver) {
        observers.remove(observer)
    }
}
