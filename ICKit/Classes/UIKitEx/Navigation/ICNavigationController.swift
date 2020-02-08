//
//  ICContentView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public enum ICNavigationBackStyle {
    case none
    case system
    case custom
}

public protocol ICNavigationClient:UIGestureRecognizerDelegate {
    func isICNavigationBarHidden() -> Bool
    func backItemStyle() -> ICNavigationBackStyle
    func isNavigationBackGestureEnabled() -> Bool
}

extension ICNavigationClient {
    public func isICNavigationBarHidden() -> Bool {
        return false
    }
    
    public func backItemStyle() -> ICNavigationBackStyle {
        return .system
    }
    
    public func isNavigationBackGestureEnabled() -> Bool {
        return true
    }
}

fileprivate class ICNavigationContext:NSObject, UINavigationControllerDelegate {
    
    weak var navigationController:ICNavigationController?
    
    init(_ navigationController:ICNavigationController) {
        super.init()
        self.navigationController = navigationController
    }
    
    @objc func backClicked() {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - UINavigationControllerDelegate
    func decorateNavigationLeftItem(for viewController:UIViewController, backItemStyle:ICNavigationBackStyle) {
        if viewController.navigationItem.leftBarButtonItem == nil {
            switch backItemStyle {
            case .none, .custom:
                viewController.navigationItem.hidesBackButton = true
                break
            case .system:
                viewController.navigationItem.hidesBackButton = false
                break
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // From ObjC-call, might be nil
        var willShowViewControllerFix:UIViewController?
        willShowViewControllerFix = viewController
        if let willShowViewController = willShowViewControllerFix {
            let currentBarHidden = navigationController.isNavigationBarHidden
            
            var nextBarHidden:Bool = false
            var backItemStyle:ICNavigationBackStyle = .system
            if let next = willShowViewController as? ICNavigationClient {
                nextBarHidden = next.isICNavigationBarHidden()
                backItemStyle = next.backItemStyle()
            }
            
            if let icNav = navigationController as? ICNavigationController, icNav.forceHideAllNavigationBar {
                nextBarHidden = true
            }
            
            if nextBarHidden != currentBarHidden {
                navigationController.setNavigationBarHidden(nextBarHidden, animated: true)
            }
            
            decorateNavigationLeftItem(for:willShowViewController, backItemStyle:backItemStyle)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}

open class ICNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    public var isGestureEnabled:Bool = true
    public var forceHideAllNavigationBar:Bool = false
    
    private lazy var naviContext:ICNavigationContext = ICNavigationContext(self)
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = naviContext
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count <= 0 {
            delegate = nil
        }
        super.setViewControllers(viewControllers, animated: animated)
        delegate = naviContext
    }
    
    //MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard isGestureEnabled else {
            return false
        }
        
        guard viewControllers.count > 1 else {
            return false
        }
        
        var backGestureEnabled:Bool = true
        if let visibleVC = visibleViewController as? ICNavigationClient {
            backGestureEnabled = visibleVC.isNavigationBackGestureEnabled()
        }
        return backGestureEnabled
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer != interactivePopGestureRecognizer
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == interactivePopGestureRecognizer
    }
}

