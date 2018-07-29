//
//  ICPopupView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICPopupView: UIView {
    
    var backgroundMask: UIControl!
    var containerView: UIView!
    var contentView: UIView!
    
    let edgeMargin = 10
    static let contentMargin: CGFloat = 20
    
    public init(containerHeight: CGFloat = 300) {
        
        super.init(frame: UIScreen.main.bounds)
        
        // Background mask
        self.backgroundMask = UIControl(frame: self.bounds)
        self.backgroundMask.backgroundColor = UIColor.black
        self.backgroundMask.alpha = 0
        self.backgroundMask.addTarget(self, action: #selector(ICPopupView.hide), for: .touchUpInside)
        self.addSubview(self.backgroundMask)
        
        // Container
        self.containerView = UIView(frame: CGRect(x: CGFloat(self.edgeMargin), y: self.bounds.maxY, width: self.bounds.width - CGFloat(self.edgeMargin*2), height: containerHeight))
        self.containerView.backgroundColor = UIColor.white
        
        self.containerView.layer.cornerRadius = 12
        self.containerView.layer.masksToBounds = true
        //        let maskLayer = CAShapeLayer()
        //        maskLayer.path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12)).cgPath
        //        self.containerView.layer.mask = maskLayer
        
        self.addSubview(self.containerView)
        
        // Main
        self.contentView = UIView(frame: UIEdgeInsetsInsetRect(self.containerView.bounds, UIEdgeInsetsMake(ICPopupView.contentMargin/2, ICPopupView.contentMargin, ICPopupView.contentMargin/2, ICPopupView.contentMargin)))
        self.containerView.addSubview(self.contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func show(inView parentView:UIView ) {
        
        parentView.addSubview(self)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations:  {
                        
                        self.backgroundMask.alpha = 0.75
                        
                        var frame: CGRect = self.containerView.frame
                        frame.origin.y = self.bounds.maxY - frame.height - CGFloat(self.edgeMargin)*3
                        self.containerView.frame = frame
        })
        { (finished) in
            
        }
    }
    
    @objc open func hide() {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
                        
                        self.backgroundMask.alpha = 0
                        
                        var frame: CGRect = self.containerView.frame
                        frame.origin.y = self.bounds.maxY
                        self.containerView.frame = frame
                        
        })
        { (finished) in
            
            self.removeFromSuperview()
        }
    }
}
