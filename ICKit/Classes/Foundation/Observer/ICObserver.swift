//
//  ICResKit.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public class ICObserverTable<T>: NSObject {
    
    lazy private var queue:DispatchQueue = DispatchQueue(label: "com.santac.observers")
    
    private var observerList:NSHashTable<AnyObject>
    public init(options:NSPointerFunctions.Options = [.weakMemory, .objectPointerPersonality]) {
        observerList = NSHashTable<AnyObject>(options: options, capacity: 2)
        super.init()
    }
    
    public func add(_ observer:T) {
        self.queue.async {
            self.observerList.add(observer as AnyObject)
        }
    }
    
    public func remove(_ observer:T) {
//        let target = observer as AnyObject
//        self.queue.async { [weak target] in
//            if let toRemove = target {
//                self.observerList.remove(toRemove)
//            }
//        }
    }
    
    public func enumerateObserver(on performQueue:DispatchQueue?, isSync:Bool = true, _ block:@escaping ((T) -> Void)) {
        
        var copyList:NSHashTable<AnyObject>? = nil
        self.queue.sync {
            copyList = self.observerList.copy() as? NSHashTable<AnyObject>
        }
        
        if let list = copyList {
            for target in list.allObjects {
                if let performQueue = performQueue {
                    if isSync {
                        if let currentQueue = OperationQueue.current?.underlyingQueue, currentQueue == performQueue {
                            block(target as! T)
                        } else {
                            performQueue.sync {
                                block(target as! T)
                            }
                        }
                    } else {
                        performQueue.async {
                            block(target as! T)
                        }
                    }
                } else {
                    block(target as! T)
                }
            }
        }
    }
    
    public func enumerateObserverOnMain(_ block:@escaping (T) -> Void) {
        if Thread.isMainThread {
            self.enumerateObserver(on: nil, block)
        } else {
            self.enumerateObserver(on: DispatchQueue.main, block)
        }
    }
    
    public func enumerateObserverOnMainAsync(_ block:@escaping ((T) -> Void)) {
        self.enumerateObserver(on: DispatchQueue.main, isSync:false, block)
    }
}

public class ICKeyObserverTable<T>: NSObject {
    lazy private var observerHash:[String:ICObserverTable<T>] = [:]
    
    lazy private var queue:DispatchQueue = DispatchQueue(label: "com.santac.keyObservers")

    public func addObserver(_ observer:T, for key:String) {
        self.queue.async {
            var table = self.observerHash[key]
            if table == nil {
                table = ICObserverTable()
                self.observerHash[key] = table
            }
            table?.add(observer)
        }
    }
    
    public func removeObserver(_ observer:T, for key:String) {
//        let target = observer as AnyObject
//        self.queue.async { [weak target] in
//            if let toRemove = target {
//                if let table = self.observerHash[key] {
//                    table.remove(toRemove as! T)
//                }
//            }
//        }
    }
    
    public func enumerateObserver(for key:String, on performQueue:DispatchQueue?, isSync:Bool = true, _ block:@escaping ((T) -> Void)) {
        var tempTable:ICObserverTable<T>?
        self.queue.sync {
            tempTable = self.observerHash[key]
        }
        
        if let table = tempTable {
            table.enumerateObserver(on:performQueue, isSync:isSync, block)
        }
    }
    
    public func enumerateObserverOnMain(for key:String, _ block:@escaping (T) -> Void) {
        self.enumerateObserver(for: key, on:DispatchQueue.main, block)
    }
    
    public func enumerateObserverOnMainAsync(for key:String, _ block:@escaping ((T) -> Void)) {
        self.enumerateObserver(for: key, on:DispatchQueue.main, isSync:false, block)
    }
}
