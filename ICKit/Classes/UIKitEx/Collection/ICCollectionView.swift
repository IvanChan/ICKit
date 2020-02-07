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

fileprivate class ScrollDelegateProxy:NSObject, UIScrollViewDelegate {
    
    weak var proxyDelegate:UIScrollViewDelegate?
    weak var delegate:UIScrollViewDelegate?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidScroll?(scrollView)
        delegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidZoom?(scrollView)
        delegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewWillBeginDragging?(scrollView)
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        proxyDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        proxyDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewWillBeginDecelerating?(scrollView)
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidEndDecelerating?(scrollView)
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        proxyDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        proxyDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidScrollToTop?(scrollView)
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }

    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        proxyDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

open class ICCollectionView: UICollectionView {
    
    private var scrollProxy = ScrollDelegateProxy()
    override public var delegate: UICollectionViewDelegate? {
        didSet {
            scrollProxy.delegate = delegate
        }
    }
    
    public weak var batchFetchingDelegate:ICCollectionViewBatchFetchingDelegate?
    private var batchFetchingContext = ICBatchFetchingContext()
    
    /// Defaults to two screenfuls.
    var leadingScreensForBatching:CGFloat = 2.0 {
        didSet {
            _checkForBatchFetching()
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        scrollProxy.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil {
            _checkForBatchFetching()
        }
    }
}

extension ICCollectionView {
    fileprivate func _checkForBatchFetching() {
        // Dragging will be handled in scrollViewWillEndDragging:withVelocity:targetContentOffset:
        if (isDragging || isTracking) {
            return;
        }
        _beginBatchFetchingIfNeeded(with: contentOffset, velocity: .zero)
    }
    
    fileprivate func _beginBatchFetchingIfNeeded(with contentOffset:CGPoint, velocity:CGPoint) {
        if batchFetchingDelegate?.shouldBeginBatchFetching() == true && batchFetchingContext.shouldFetchBatch(for: self, leadingScreens: leadingScreensForBatching, contentOffset: contentOffset, velocity: velocity) {
            _beginBatchFetching()
        }
    }
    
    fileprivate func _beginBatchFetching() {
        batchFetchingContext.beginBatchFetching()
        batchFetchingDelegate?.startBatchFetching(with: batchFetchingContext)
    }
}

extension ICCollectionView: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        _beginBatchFetchingIfNeeded(with: targetContentOffset.pointee, velocity: velocity)
    }
}
