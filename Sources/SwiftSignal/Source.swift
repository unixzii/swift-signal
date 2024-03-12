/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

/// The source primitive that computations use.
protocol Source {
    
    func removeObserver(_ observer: AnyObserver)
}
