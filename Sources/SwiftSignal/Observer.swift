/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

/// A type that receives notifications when underlying source changes.
protocol Observer {
    
    func addSource(_ source: any Source)
    
    func notify()
}

/// A type-erased observer.
class AnyObserver: Equatable, Hashable {
    
    private let observer: any Observer
    
    static func == (lhs: AnyObserver, rhs: AnyObserver) -> Bool {
        return lhs === rhs
    }
    
    init(observer: any Observer) {
        self.observer = observer
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    func addSource(_ source: any Source) {
        observer.addSource(source)
    }
    
    func notify() {
        observer.notify()
    }
}
