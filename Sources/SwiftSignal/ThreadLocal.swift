/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

import Foundation

// TODO: Get rid of the Foundation types.
struct ThreadLocal<T> {
    
    private class Box<V>: NSObject {
        
        static var key: NSString {
            return NSStringFromClass(Self.self) as NSString
        }
        
        var value: V
        
        init(value: V) {
            self.value = value
        }
    }
    
    static var value: T? {
        get {
            let threadDictionary = Thread.current.threadDictionary
            let maybeBox = threadDictionary.object(forKey: Box<T>.key)
            guard let box = maybeBox as? Box<T> else {
                return nil
            }
            return box.value
        }
        set {
            let threadDictionary = Thread.current.threadDictionary
            guard let newValue else {
                threadDictionary.removeObject(forKey: Box<T>.key)
                return
            }
            
            let maybeBox = threadDictionary.object(forKey: Box<T>.key)
            guard let box = maybeBox as? Box<T> else {
                threadDictionary.setObject(Box(value: newValue), forKey: Box<T>.key)
                return
            }
            box.value = newValue
        }
    }
}
