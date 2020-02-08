//
//  ICPopupView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICPopupView: UIView {
    
    public lazy var backgroundMask: UIControl = {
        let view = UIControl(frame: self.bounds)
        view.backgroundColor = UIColor.black
        view.alpha = 0
        view.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return view
    }()
    
    public lazy var containerView: UIView = {
        let containerView = UIView(frame: CGRect(x: CGFloat(edgeMargin), y: bounds.maxY, width: bounds.width - CGFloat(edgeMargin*2), height: 0))
        containerView.backgroundColor = UIColor.white
        
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        //        let maskLayer = CAShapeLayer()
        //        maskLayer.path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12)).cgPath
        //        self.containerView.layer.mask = maskLayer
        
        return containerView
    }()
    
    public lazy var contentView: UIView = {
        let contentView = UIView(frame: containerView.bounds.inset(by: UIEdgeInsets(top: contentMargin/2, left: contentMargin, bottom: contentMargin/2, right: contentMargin)))
        return contentView
    }()
    
    public let edgeMargin = 10
    var contentMargin: CGFloat = 20 {
        didSet {
            contentView.frame = containerView.bounds.inset(by: UIEdgeInsets(top: contentMargin/2, left: contentMargin, bottom: contentMargin/2, right: contentMargin))
        }
    }
    
    public init(containerHeight: CGFloat = 300) {
        
        super.init(frame: UIScreen.main.bounds)
        
        // Background mask
        addSubview(backgroundMask)
        
        // Container
        containerView.frame.size.height = containerHeight
        addSubview(containerView)
        
        // Main
        containerView.addSubview(contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func show(inView parentView:UIView? ) {
        
        if parentView == nil {
            return
        }
        
        parentView?.addSubview(self)
        
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
