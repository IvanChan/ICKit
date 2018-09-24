//
//  ICContentView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICContentView: UIView {
    
    public lazy var contentView: UIView = {
        let contentView = UIView()
        self.addSubview(contentView)
        return contentView
    }()
    
    override open var frame: CGRect {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public init(frame: CGRect, contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)) {
        super.init(frame: frame)
        self.contentInsets = contentInsets
        self.contentView.frame = self.bounds.inset(by: self.contentInsets)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds.inset(by: self.contentInsets)
    }
}
