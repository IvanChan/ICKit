//
//  DispatchQueueExtension.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/16.
//

import UIKit

extension DispatchQueue {
    public class func mainSync(execute block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            self.main.sync(execute:block)
        }
    }
}
