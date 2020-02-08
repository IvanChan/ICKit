//
//  ICContentView.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICContentView: UIView {
    
    public lazy var contentView: UIView = UIView()
    
    override open var frame: CGRect {
        didSet {
            self.contentView.frame = self.bounds.inset(by: self.contentInsets)
        }
    }
    
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.contentView.frame = self.bounds.inset(by: self.contentInsets)
        }
    }
    
    public init(frame: CGRect, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)) {
        super.init(frame: frame)
        self.contentInsets = contentInsets
        contentView.frame = bounds.inset(by: self.contentInsets)
        addSubview(contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
