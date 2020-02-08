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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.alpha = 0
        view.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return view
    }()
    
    public lazy var containerView: ICContentView = {
        let containerView = ICContentView(frame: CGRect(x: CGFloat(edgeMargin), y: bounds.maxY, width: bounds.width - CGFloat(edgeMargin*2), height: 0))
        containerView.backgroundColor = UIColor.white
        
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        //        let maskLayer = CAShapeLayer()
        //        maskLayer.path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12)).cgPath
        //        self.containerView.layer.mask = maskLayer
        
        return containerView
    }()
    
    public var contentView:UIView {
        return containerView.contentView
    }
    
    var edgeMargin:CGFloat = 10 {
        didSet {
            containerView.frame.origin.x = edgeMargin
            containerView.frame.size.width = bounds.width - edgeMargin*2
        }
    }
    
    public init(contentHeight: CGFloat = 300) {

        super.init(frame: UIScreen.main.bounds)
        
        // Background mask
        addSubview(backgroundMask)
        
        // Container
        let containerHeight = contentHeight + containerView.contentInsets.top + containerView.contentInsets.bottom
        containerView.frame.size.height = containerHeight
        addSubview(containerView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func show(inView parentView:UIView) {
        
        parentView.addSubview(self)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations:  {
                        
                        self.backgroundMask.alpha = 1
                        
                        var frame: CGRect = self.containerView.frame
                        frame.origin.y = self.bounds.maxY - frame.height - self.edgeMargin - UIScreen.main.ic.safeArea().bottom
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
