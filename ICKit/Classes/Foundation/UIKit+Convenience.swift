//
//  UIKit+Convenience.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension CGRect {
    public init(_ xx: CGFloat, _ yy: CGFloat, _ ww:CGFloat, _ hh:CGFloat) {
        
        self.init()
        
        self.origin.x = xx
        self.origin.y = yy
        self.size.width = ww
        self.size.height = hh
    }
}

extension CGPoint {
    public init(_ xx: CGFloat, _ yy: CGFloat) {
        
        self.init()
        
        self.x = xx
        self.y = yy
    }
}

extension CGSize {
    public init(_ ww:CGFloat, _ hh:CGFloat) {
        
        self.init()

        self.width = ww
        self.height = hh
    }
}
