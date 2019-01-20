//
//  UIViewController+Container.swift
//  Ico
//
//  Created by _ivanC on 11/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit
extension ICKit where Base : UIViewController {

    public func displayContentController(contentViewController: UIViewController, onView: UIView) {
        
        base.addChild(contentViewController)
        onView.addSubview(contentViewController.view)
        
        contentViewController.didMove(toParent: base)
    }
    
    public func displayContentController(contentViewController: UIViewController) {
        
        self.displayContentController(contentViewController: contentViewController, onView: base.view)
    }
    
    
    public func hideContentController(contentViewController: UIViewController) {
        
        contentViewController.ic.hideFromParentViewController()
    }
    
    public func hideFromParentViewController() {
        
        base.willMove(toParent: nil)
        
        base.view.removeFromSuperview()
        base.removeFromParent()
    }
}
