//
//  UIScreen+Utilities.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension ICKit where Base == UIScreen {
    
    public func safeArea() -> UIEdgeInsets {
        var insets = UIEdgeInsets.zero
        
        if let appDelegate = UIApplication.shared.delegate {
            if let appWindow = appDelegate.window as? UIWindow {
                if #available(iOS 11.0, *) {
                    insets = appWindow.safeAreaInsets
                } else {
                    // Fallback on earlier versions
                    if let rootViewController = appWindow.rootViewController {
                        insets = UIEdgeInsets(top: rootViewController.topLayoutGuide.length,
                                              left: 0,
                                              bottom: rootViewController.bottomLayoutGuide.length,
                                              right: 0)
                    }
                }
            }
        }
        
        return insets
    }
    
    public func isAlmostFullScreenDevice() -> Bool {
        let safeArea = self.safeArea()
        return safeArea.top == 44 && safeArea.bottom == 34
    }
}

