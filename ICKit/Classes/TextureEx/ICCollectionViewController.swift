//
//  ICTextNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/3.
//  Copyright © 2019 _ivanc. All rights reserved.
//

import UIKit

public class ICCollectionViewController: UIViewController {
    
    private var batchFetchingContext = ICBatchFetchingContext()
    var leadingScreensForBatching:CGFloat = 2.0 // Defaults to two screenfuls.
    
    private(set) lazy var collectionView:UICollectionView = {
        let view = UICollectionView()
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _checkForBatchFetching()
    }
}

extension ICCollectionViewController {
    fileprivate func _checkForBatchFetching() {
        // Dragging will be handled in scrollViewWillEndDragging:withVelocity:targetContentOffset:
        if (collectionView.isDragging || collectionView.isTracking) {
            return;
        }
        _beginBatchFetchingIfNeeded(with: collectionView.contentOffset, velocity: .zero)
    }
    
    fileprivate func _beginBatchFetchingIfNeeded(with contentOffset:CGPoint, velocity:CGPoint) {
        if shouldBeginBatchFetching() && batchFetchingContext.shouldFetchBatch(for: collectionView, leadingScreens: leadingScreensForBatching, contentOffset: contentOffset, velocity: velocity) {
            _beginBatchFetching()
        }
    }
    
    fileprivate func _beginBatchFetching() {
        batchFetchingContext.beginBatchFetching()
        startBatchFetching(with: batchFetchingContext)
    }
    
    internal func shouldBeginBatchFetching() -> Bool {
        return true
    }
    
    internal func startBatchFetching(with context:ICBatchFetchingContext) {
        
    }
}

extension ICCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        _beginBatchFetchingIfNeeded(with: targetContentOffset.pointee, velocity: velocity)
    }
}
