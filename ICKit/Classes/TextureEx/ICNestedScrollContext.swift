//
//  ICNestedScrollContext.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/16.
//  Copyright © 2019 ivanC. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class ICNestedMainScrollView: UIScrollView, UIGestureRecognizerDelegate {
    //底层tableView实现这个UIGestureRecognizerDelegate的方法，从而可以接收并响应上层tabelView的滑动手势，otherGestureRecognizer就是它上层View也持有的Gesture，这里在它上层的有scrollView和顶层tableView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //        保证其它手势的View存在
        guard let otherView = otherGestureRecognizer.view else {
            return false
        }
        //如果其它手势的View是scrollView的手势，肯定是不能同时响应的
        if otherView.isMember(of: UIScrollView.self) {
            return false
        }
        //    其它手势是collectionView 或者tableView的pan手势 ，那么就让它们同时响应
        let isPan = gestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        
        if isPan && otherView.isKind(of: UIScrollView.self) {
            return true
        }
        
        return false
    }
}

public protocol ICNestedScrollContextDataSource:NSObjectProtocol {
    func mainScrollView() -> ICNestedMainScrollView?
    func embeddedScrollView() -> UIScrollView?
    func triggerOffset() -> CGPoint
}

public class ICNestedScrollContext: NSObject, UIScrollViewDelegate {
    
    weak var dataSource:ICNestedScrollContextDataSource?
    
    private var mainScrollView:ICNestedMainScrollView? {
        return dataSource?.mainScrollView()
    }
    
    private var embeddedScrollView:UIScrollView? {
        return dataSource?.embeddedScrollView()
    }
    
    private var triggerOffset:CGPoint {
        return dataSource?.triggerOffset() ?? .zero
    }

    private(set) var isMainScrollViewDragging:Bool = false
    private(set) var isEmbeddedScrollViewDragging:Bool = false

    public var deceleratingFactor:CGFloat = 120
    
    public init(dataSource:ICNestedScrollContextDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    private var fixTriggerOffsetY:CGFloat = 0
    @objc public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        if scrollView == mainScrollView {
            mainContentOffset = scrollView.contentOffset
            isMainScrollViewDragging = true
            
            fixTriggerOffsetY = triggerOffset.y
            
//            var mainScrollViewContentInset = scrollView.contentInset
//            if #available(iOS 11.0, *) {
//                mainScrollViewContentInset = scrollView.adjustedContentInset
//            }
//
//            let mainScrollViewMaxContentOffsetY = scrollView.contentSize.height - scrollView.bounds.height + mainScrollViewContentInset.bottom
//            if fixTriggerOffsetY > mainScrollViewMaxContentOffsetY {
//                fixTriggerOffsetY = mainScrollViewMaxContentOffsetY
//            }
        } else if scrollView == embeddedScrollView {
            embeddedContentOffset = scrollView.contentOffset
            isEmbeddedScrollViewDragging = true
        }
        

    }
    
    private var mainContentOffset:CGPoint = .zero
    private var embeddedContentOffset:CGPoint = .zero
    private var isMainScrolling = false
    private var isEmbeddedScrolling = false
    @objc public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == mainScrollView {
            let isScrollingDown = mainContentOffset.y > scrollView.contentOffset.y
            if scrollView.contentOffset.y > fixTriggerOffsetY || (isScrollingDown && embeddedContentOffset.y > 0 && isEmbeddedScrolling) {
                scrollView.contentOffset.y = fixTriggerOffsetY
                isMainScrolling = false
            } else {
                isMainScrolling = true
            }
            
            mainContentOffset = scrollView.contentOffset
        } else if scrollView == embeddedScrollView {

            if mainContentOffset.y < fixTriggerOffsetY && isMainScrolling {
                scrollView.contentOffset = embeddedContentOffset
                isEmbeddedScrolling = false
            } else {
                isEmbeddedScrolling = true
            }
            
            if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset.y = 0
            }
            embeddedContentOffset = scrollView.contentOffset
        }
    }
    
    @objc public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == mainScrollView {
            isMainScrollViewDragging = false
        } else if scrollView == embeddedScrollView {
            isEmbeddedScrollViewDragging = false
        }
    }
}
