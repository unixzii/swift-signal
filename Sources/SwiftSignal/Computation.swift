/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

/// The reactive primitive that is derived from other primitives.
///
/// A computation usually represents two things: **Effect** and
/// **Computed**. It is the base abstraction for those higher level
/// APIs.
class Computation<T: Equatable>: Source {
    
    class _Observer<V: Equatable>: Observer {
        
        weak var owner: Computation<V>?
        
        init(_ owner: Computation<V>) {
            self.owner = owner
        }
        
        func addSource(_ source: Source) {
            owner?.sources.append(source)
        }
        
        func notify() {
            guard let owner else {
                return
            }
            
            owner.isDirty = true
            
            // Re-run the computation for effects.
            if !owner.isPure {
                owner.update()
            }
            
            for observer in owner.observers {
                observer.notify()
            }
        }
    }
    
    let fn: () -> T
    let isPure: Bool
    
    private(set) var currentValue: T?
    #if DEBUG
    private(set) var version = 0
    #endif
    private(set) var observers = Set<AnyObserver>()
    private(set) var isDirty = true
    private(set) var sources = [any Source]()
    
    private var selfAsObserver: AnyObserver!
    private var lastObserver: AnyObserver?
    
    deinit {
        for source in sources {
            source.removeObserver(selfAsObserver)
        }
    }
    
    var value: T {
        if isDirty {
            update()
        }
        if let observer = CurrentObserver.value {
            observer.addSource(self)
            observers.insert(observer)
        }
        return currentValue!
    }
    
    init(_ fn: @escaping () -> T, initialValue: T?) {
        self.currentValue = initialValue
        self.fn = fn
        self.isPure = true
        
        commonInit()
    }
    
    init(_ fn: @escaping () -> T) {
        self.currentValue = nil
        self.fn = fn
        self.isPure = false
        
        commonInit()
    }
    
    private func commonInit() {
        selfAsObserver = .init(observer: _Observer(self))
    }
    
    func removeObserver(_ observer: AnyObserver) {
        self.observers.remove(observer)
    }
    
    func update() {
        for source in sources {
            source.removeObserver(selfAsObserver)
        }
        sources = []
        
        startTracking()
        let newValue = fn()
        endTracking()
        
        isDirty = false
        
        if newValue == currentValue {
            // Computed value is not changed, don't mark dirty
            // for downstream computations.
            return
        }
        
        self.currentValue = newValue
        #if DEBUG
        self.version += 1
        #endif
    }
    
    private func startTracking() {
        lastObserver = CurrentObserver.value
        CurrentObserver.value = selfAsObserver
    }
    
    private func endTracking() {
        CurrentObserver.value = lastObserver
    }
}

public typealias ComputedGetter<T> = () -> T
public typealias DisposeAction = () -> ()

/// Creates a computed reactive value that returns the value of the
/// given closure.
///
/// It's guaranteed that the closure will only get executed when its
/// dependencies change.
public func createComputed<T: Equatable>(_ fn: @escaping () -> T) -> ComputedGetter<T> {
    let computation = Computation<T>(fn, initialValue: nil)
    return {
        return computation.value
    }
}

/// Creates an effect that will run automatically when its dependencies
/// change, and returns a closure to dispose the effect.
public func createEffect(_ fn: @escaping () -> DisposeAction?) -> DisposeAction {
    class _Ref {
        
        var computation: Computation<Int>?
        var cleanup: DisposeAction?
        
        deinit {
            cleanup?()
        }
    }
    
    let ref = _Ref()
    
    let computation = Computation<Int> { [unowned ref] in
        ref.cleanup?()
        ref.cleanup = fn()
        return 0
    }
    computation.update()
    
    ref.computation = computation
    
    return {
        ref.computation = nil
        ref.cleanup?()
        ref.cleanup = nil
    }
}
