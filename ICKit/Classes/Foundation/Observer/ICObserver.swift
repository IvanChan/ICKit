//
//  ICResKit.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public class ICObserverTable<T>: NSObject {
    lazy private var observerList:NSHashTable = {
        return NSHashTable<AnyObject>(options: [.weakMemory, .objectPointerPersonality], capacity: 2)
    }()
    
    lazy private var addObserverList:NSHashTable = {
        return NSHashTable<AnyObject>(options: [.weakMemory, .objectPointerPersonality], capacity: 2)
    }()
    
    lazy private var removeObserverList:NSHashTable = {
        return NSHashTable<AnyObject>(options: [.weakMemory, .objectPointerPersonality], capacity: 2)
    }()
    
    lazy private var lock:NSRecursiveLock = NSRecursiveLock()
    
    lazy private var isEnumerating:Bool = false
    
    public func observerCount() -> Int {
        
        var count:Int = 0
        self.lock.lock()
        count = self.observerList.count
        self.lock.unlock()
        return count
    }
    
    public func addObserver(_ observer:T) {
        self.lock.lock()
        
        if self.isEnumerating {
            self.addObserverList.add(observer as AnyObject)
        } else {
            self.observerList.add(observer as AnyObject)
        }
        
        self.lock.unlock()
    }
    
    public func removeObserver(_ observer:T) {
        self.lock.lock()
        
        if self.isEnumerating {
            self.removeObserverList.add(observer as AnyObject)
        } else {
            self.observerList.remove(observer as AnyObject)
        }
        
        self.lock.unlock()
    }
    
    public func enumerateObserver(_ block:((T) -> Void)) {
        self.lock.lock()
        self.isEnumerating = true
        
        for target in self.observerList.allObjects {
            block(target as! T)
        }
        
        // merging data
        self.observerList.union(self.addObserverList)
        self.observerList.minus(self.removeObserverList)
        
        self.addObserverList.removeAllObjects()
        self.removeObserverList.removeAllObjects()
        
        self.lock.unlock()
    }
    
    public func enumerateObserverOnMain(_ block:(T) -> Void) {
        if Thread.isMainThread {
            self.enumerateObserver(block)
        } else {
            DispatchQueue.main.sync {
                self.enumerateObserver(block)
            }
        }
    }
    
    public func enumerateObserverOnMainAsync(_ block:@escaping ((T) -> Void)) {
        DispatchQueue.main.async {
            self.enumerateObserver(block)
        }
    }
}

public class ICKeyObserverTable<T>: NSObject {
    lazy private var observerHash:[String:ICObserverTable<T>] = [:]
    
    lazy private var lock:NSRecursiveLock = NSRecursiveLock()

    public func addObserver(_ observer:T, for key:String) {
        self.lock.lock()
        
        var table = self.observerHash[key]
        if table == nil {
            table = ICObserverTable()
            self.observerHash[key] = table
        }
        table?.addObserver(observer)
        
        self.lock.unlock()
    }
    
    public func removeObserver(_ observer:T, for key:String) {
        self.lock.lock()
        
        if let table = self.observerHash[key] {
            table.removeObserver(observer)
            if table.observerCount() <= 0 {
                self.observerHash.removeValue(forKey: key)
            }
        }
        
        self.lock.unlock()
    }
    
    public func enumerateObserver(for key:String, _ block:((T) -> Void)) {
        self.lock.lock()
        
        if let table = self.observerHash[key] {
            table.enumerateObserver(block)
        }
    
        self.lock.unlock()
    }
    
    public func enumerateObserverOnMain(for key:String, _ block:(T) -> Void) {
        if Thread.isMainThread {
            self.enumerateObserver(for:key, block)
        } else {
            DispatchQueue.main.sync {
                self.enumerateObserver(for:key, block)
            }
        }
    }
    
    public func enumerateObserverOnMainAsync(for key:String, _ block:@escaping ((T) -> Void), sync:Bool = false) {
        DispatchQueue.main.async {
            self.enumerateObserver(for:key, block)
        }
    }
}
