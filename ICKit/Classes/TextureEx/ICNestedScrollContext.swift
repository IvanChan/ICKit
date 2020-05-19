//
//  ICNestedScrollContext.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/16.
//  Copyright © 2019 ivanC. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public protocol ICNestedScrollContextDataSource:NSObjectProtocol {
    func mainScrollView() -> UIScrollView?
    func embeddedScrollView() -> UIScrollView?
    func triggerOffset() -> CGPoint
}

public class ICNestedScrollContext: NSObject, UIScrollViewDelegate {
    
    weak var dataSource:ICNestedScrollContextDataSource?
    
    private var mainScrollView:UIScrollView? {
        return self.dataSource?.mainScrollView()
    }
    
    private var embeddedScrollView:UIScrollView? {
        return self.dataSource?.embeddedScrollView()
    }
    
    private var triggerOffset:CGPoint {
        return self.dataSource?.triggerOffset() ?? .zero
    }

    private(set) var isMainScrollViewDragging:Bool = false
    private(set) var isEmbeddedScrollViewDragging:Bool = false

    public var deceleratingFactor:CGFloat = 120
    
    public init(dataSource:ICNestedScrollContextDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    @objc public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let embeddedScrollView = self.embeddedScrollView, let mainScrollView = self.mainScrollView else {return}

        if scrollView == mainScrollView {
            isMainScrollViewDragging = true
        } else if scrollView == embeddedScrollView {
            isEmbeddedScrollViewDragging = true
        }
    }
    
    @objc public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let embeddedScrollView = self.embeddedScrollView, let mainScrollView = self.mainScrollView else {return}

        if scrollView == mainScrollView {
            if isEmbeddedScrollViewDragging {
                return
            }
            
            let triggerOffset = self.triggerOffset
            
            let scrollStep = scrollView.contentOffset.y - triggerOffset.y
            if scrollStep > 0 {
                var pos = scrollView.contentOffset
                pos.y = triggerOffset.y
                scrollView.contentOffset = pos
                
                var flowPos = embeddedScrollView.contentOffset
                flowPos.y = flowPos.y + scrollStep
                if !isMainScrollViewDragging {
                    let maxOffsetY = max(0, embeddedScrollView.contentSize.height - embeddedScrollView.bounds.height)
                    flowPos.y = min(max(0, flowPos.y), maxOffsetY)
                }
                embeddedScrollView.setContentOffsetWithoutNotifyDelegate(flowPos)
                
            } else {
                if embeddedScrollView.contentOffset.y > 0 {
                    var flowPos = embeddedScrollView.contentOffset
                    flowPos.y = flowPos.y + (scrollView.contentOffset.y - triggerOffset.y)
                    flowPos.y = max(0, flowPos.y)
                    embeddedScrollView.setContentOffsetWithoutNotifyDelegate(flowPos)
                    
                    var pos = scrollView.contentOffset
                    pos.y = triggerOffset.y
                    scrollView.contentOffset = pos
                }
            }
        } else if scrollView == embeddedScrollView {
            if isMainScrollViewDragging {
                return
            }
            
            let triggerOffset = self.triggerOffset

            let mainCurrentY = mainScrollView.contentOffset.y
            let isScrollToListArea = mainCurrentY >= triggerOffset.y
            
            if !isScrollToListArea || scrollView.contentOffset.y < 0 {
                
                var pos = mainScrollView.contentOffset
                pos.y = min(pos.y + scrollView.contentOffset.y, triggerOffset.y)
                if !isEmbeddedScrollViewDragging {
                    pos.y = max(0, pos.y)
                }
                
                mainScrollView.setContentOffsetWithoutNotifyDelegate(pos)
                
                scrollView.contentOffset = .zero
            }
        }
    }
    
    @objc public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let embeddedScrollView = self.embeddedScrollView, let mainScrollView = self.mainScrollView else {return}

        if scrollView == mainScrollView {
            isMainScrollViewDragging = false
            
            let maxOffsetY = max(0, embeddedScrollView.contentSize.height - embeddedScrollView.bounds.height)
            if embeddedScrollView.contentOffset.y > maxOffsetY {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                               animations: {
                                var pos = embeddedScrollView.contentOffset
                                pos.y = maxOffsetY
                                embeddedScrollView.setContentOffsetWithoutNotifyDelegate(pos)
                                
                }) { (finished) in }
            } else if embeddedScrollView.contentOffset.y < maxOffsetY && embeddedScrollView.contentOffset.y > 0 {
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                               animations: {
                                
                                var pos = embeddedScrollView.contentOffset
                                pos.y = max(0, min(pos.y + velocity.y*self.deceleratingFactor, maxOffsetY))
                                
                                embeddedScrollView.setContentOffsetWithoutNotifyDelegate(pos)
                                
                }) { (finished) in }
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                               animations: {
                                embeddedScrollView.setContentOffsetWithoutNotifyDelegate(.zero)
                                
                }) { (finished) in }
            }
        } else if scrollView == embeddedScrollView {
            isEmbeddedScrollViewDragging = false
            
            let triggerOffset = self.triggerOffset

            if mainScrollView.contentOffset.y > 0 {
                
                // if embeddedScrollView still not at top end
                // let didscroll do its work
                if embeddedScrollView.contentOffset.y <= 0 {
                    UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                                   animations: {
                                    
                                    var pos = mainScrollView.contentOffset
                                    pos.y = max(0, min(pos.y + velocity.y*self.deceleratingFactor, triggerOffset.y))
                                    
                                    mainScrollView.setContentOffsetWithoutNotifyDelegate(pos)
                                    
                    }) { (finished) in }
                }
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                               animations: {
                                mainScrollView.setContentOffsetWithoutNotifyDelegate(.zero)
                                
                }) { (finished) in }
            }
        }
    }
}

extension UIScrollView {
    func setContentOffsetWithoutNotifyDelegate(_ offset:CGPoint) {
        
        if let tableView = self as? ASTableView, let node = tableView.tableNode {
            
            let delegate = node.delegate
            
            node.delegate = nil
            self.contentOffset = offset
            node.delegate = delegate
        } else {
            let delegate = self.delegate
            
            self.delegate = nil
            self.contentOffset = offset
            self.delegate = delegate
        }
    }
}
