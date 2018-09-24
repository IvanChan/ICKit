//
//  ICBottomBar.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICBottomBar: ICContentView {

    public init(frame: CGRect) {
        let deviceBottomMarginHeight = UIScreen.main.ic.safeArea().bottom
        var cFrame = frame
        cFrame.size.height += deviceBottomMarginHeight
        super.init(frame: cFrame, contentInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: deviceBottomMarginHeight, right: 0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
