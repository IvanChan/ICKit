//
//  ICTextNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/3.
//  Copyright © 2019 _ivanc. All rights reserved.
//

import UIKit

public class ICBatchFetchingContext {
    
    private(set) var isFetching:Bool = false
    func shouldFetchBatch(for scrollView:UIScrollView, leadingScreens:CGFloat, contentOffset:CGPoint,  velocity:CGPoint) -> Bool {
        return shouldFetchBatch(scrollViewBounds: scrollView.bounds, contentSize: scrollView.contentSize, targetOffset: contentOffset, leadingScreens: leadingScreens, visible: scrollView.window != nil, velocity: velocity)
    }
    
    func shouldFetchBatch(scrollViewBounds:CGRect,
                          contentSize:CGSize,
                          targetOffset:CGPoint,
                          leadingScreens:CGFloat,
                          visible:Bool,
                          velocity:CGPoint) -> Bool {
        // Do not allow fetching if a batch is already in-flight and hasn't been completed or cancelled
        if isFetching {
            return false
        }
        
        // No fetching for null states
        if leadingScreens <= 0.0 || scrollViewBounds.isEmpty {
            return false
        }
        
        let viewLength = scrollViewBounds.size.height
        let offset = targetOffset.y
        let contentLength = contentSize.height
        //        let velocityLength = velocity.y
        
        let hasSmallContent:Bool = contentLength < viewLength
        if hasSmallContent {
            return true
        }
        
        // If we are not visible, but we do have enough content to fill visible area,
        // don't batch fetch.
        if !visible {
            return false
        }
        
        let triggerDistance = viewLength * leadingScreens;
        let remainingDistance = contentLength - viewLength - offset;
        let result = remainingDistance <= triggerDistance;
        return result;
    }
}

extension ICBatchFetchingContext {
    func beginBatchFetching() {
        isFetching = true
    }
    
    func completeBatchFetching(_ didComplete:Bool) {
        isFetching = false
    }
}

public protocol ICCollectionViewBatchFetchingDelegate: NSObjectProtocol {
    func shouldBeginBatchFetching() -> Bool
    func startBatchFetching(with context:ICBatchFetchingContext)
}

open class ICCollectionView: UICollectionView {

    public weak var batchFetchingDelegate:ICCollectionViewBatchFetchingDelegate?
    private var batchFetchingContext = ICBatchFetchingContext()
    
    /// Defaults to two screenfuls.
    var leadingScreensForBatching:CGFloat = 2.0 {
        didSet {
            checkForBatchFetching()
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        checkForBatchFetching()
    }
}

extension ICCollectionView {
    func checkForBatchFetching() {
        // Dragging will be handled in scrollViewWillEndDragging:withVelocity:targetContentOffset:
        if (window == nil || isDragging || isTracking) {
            return
        }
        beginBatchFetchingIfNeeded(with: contentOffset, velocity: .zero)
    }
    
    func beginBatchFetchingIfNeeded(with contentOffset:CGPoint, velocity:CGPoint) {
        if batchFetchingDelegate?.shouldBeginBatchFetching() == true && batchFetchingContext.shouldFetchBatch(for: self, leadingScreens: leadingScreensForBatching, contentOffset: contentOffset, velocity: velocity) {
            _beginBatchFetching()
        }
    }
    
    fileprivate func _beginBatchFetching() {
        batchFetchingContext.beginBatchFetching()
        batchFetchingDelegate?.startBatchFetching(with: batchFetchingContext)
    }
}
