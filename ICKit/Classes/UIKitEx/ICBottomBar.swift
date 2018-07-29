//
//  ICBottomBar.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit
import ICFoundation

open class ICBottomBar: ICContentView {

    init(frame: CGRect) {
        let deviceBottomMarginHeight = UIScreen.main.ic.deviceBottomMarginHeight()
        var cFrame = frame
        cFrame.size.height += deviceBottomMarginHeight
        super.init(frame: cFrame, contentInsets: UIEdgeInsetsMake(0, 0, deviceBottomMarginHeight, 0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
