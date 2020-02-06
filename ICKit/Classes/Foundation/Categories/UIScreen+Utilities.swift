//
//  UIScreen+Utilities.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension ICKit where Base == UIScreen {
    
    @available(iOSApplicationExtension, unavailable)
    public func safeArea() -> UIEdgeInsets {
           var insets = UIEdgeInsets.zero
        
           DispatchQueue.mainSync {
               if let appDelegate = UIApplication.shared.delegate {
                   if let appWindow = appDelegate.window as? UIWindow {
                       if #available(iOS 12.0, *) {
                           insets = appWindow.safeAreaInsets
                       } else if #available(iOS 11.0, *) {
                           if let rootViewController = appWindow.rootViewController {
                               let layoutFrame = rootViewController.view.safeAreaLayoutGuide.layoutFrame
                               insets = UIEdgeInsets(top: layoutFrame.origin.y,
                                                     left: 0,
                                                     bottom: rootViewController.view.frame.height - layoutFrame.maxY,
                                                     right: 0)
                           }
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
           }
           
           return insets
       }
}

