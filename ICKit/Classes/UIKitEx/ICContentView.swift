//
//  ICContentView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICContentView: UIView {
    
    lazy var contentView: UIView = {
        let contentView = UIView()
        self.addSubview(contentView)
        return contentView
    }()
    
    override open var frame: CGRect {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public init(frame: CGRect, contentInsets: UIEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)) {
        super.init(frame: frame)
        self.contentInsets = contentInsets
        self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)
    }
}
