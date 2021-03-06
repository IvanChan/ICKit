//
//  ICTextNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/3.
//  Copyright © 2019 _ivanc. All rights reserved.
//

import UIKit

public typealias T = Any
open class ICCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public private(set) lazy var collectionView:ICCollectionView = {
        let view = ICCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(nibName: nil, bundle: nil)
        collectionView.collectionViewLayout = layout
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }

    //MARK: - Loading
    public var isLoadingNewData:Bool = false
    public var isLoadingMoreData:Bool = false
    public var hasMoreData:Bool = true
    public private(set) var isFirstLoad:Bool = true
    
    //MARK: - DataItem
    public lazy var sectionItems:[[T]] = []
    
    //MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionItemCount(at: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.checkForBatchFetching()
    }
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.beginBatchFetchingIfNeeded(with: targetContentOffset.pointee, velocity: velocity)
     }
}

//MARK: - ICCollectionViewBatchFetchingDelegate
extension ICCollectionViewController: ICCollectionViewBatchFetchingDelegate {
    public func shouldBeginBatchFetching() -> Bool {
        return true
    }
    
    public func startBatchFetching(with context: ICBatchFetchingContext) {
        fetchMoreData(context)
    }
}

//MARK: - Loading
extension ICCollectionViewController {
    
    public func isLoadingData() -> Bool {
        return self.isLoadingNewData || self.isLoadingMoreData
    }

    //MARK: Load New
    public func shouldLoadNewData() -> Bool {
        return !self.isLoadingData()
    }
    
    public func willLoadNewData() {
        
    }
    
    final func fetchNewData() {
        DispatchQueue.mainSync { [weak self] in
            guard let self = self else {return}

            if !self.shouldLoadNewData() {
                return
            }
            
            self.isLoadingNewData = true
            self.willLoadNewData()
            self.loadNewData(isFirstLoad: self.isFirstLoad) { [weak self] (results, error, hasMore) in
                guard let self = self else {return}
                
                let finishLoadData = { [weak self] in
                    guard let self = self else {return}
                    self.processLoadNewDataResult(results, error, false, self.isFirstLoad) { [weak self] in
                        guard let self = self else {return}
                        DispatchQueue.mainSync { [weak self] in
                            guard let self = self else {return}

                            let isFirstLoad = self.isFirstLoad
                            self.isFirstLoad = false
                            self.hasMoreData = hasMore
                            self.isLoadingNewData = false
                            self.didFinishLoadNewData(results, error, hasMore, isFirstLoad)
                        }
                    }
                }
                
                DispatchQueue.main.async { finishLoadData() }
            }
        }
    }
    
    /// Override to customise your own load new data logic
    ///
    /// - Parameter completion: You HAVE TO call the completion as soon as you're finished performing that operation
    public func loadNewData(isFirstLoad:Bool, _ completion: @escaping (_ results:[T], _ error:Error?, _ hasMore:Bool)->Swift.Void) {
        completion([], nil, false)
    }
    
    /// Process your new data here
    ///
    /// - Parameters:
    ///   - results: Data from loadNewData
    ///   - error: Loading error, nil means succeed
    ///   - processCompletion: finish process data, you HAVE TO call the processCompletion as soon as you're finished performing that operation
    public func processLoadNewDataResult(_ results:[T], _ error:Error?, _ shouldClearOldData:Bool, _ isFirstLoad:Bool, _ processCompletion:@escaping ()->Void) {
        guard results.count > 0 else {
            if shouldClearOldData {
                sectionItems.removeAll()
            }

            collectionView.performBatchUpdates({
                collectionView.reloadData()
            }, completion: { (finished) in
                processCompletion()
            })
            
            return
        }
        
        DispatchQueue.mainSync { [weak self] in
            guard let self = self else {return}

            if shouldClearOldData {
                sectionItems.removeAll()
                self.sectionItems.append(results)

                collectionView.performBatchUpdates({
                collectionView.reloadData()
                }, completion: { (finished) in
                    processCompletion()
                })
            } else if results.count <= 0 {
                processCompletion()
            } else if var rowDataItems = sectionItems.first {
                rowDataItems = results + rowDataItems
                sectionItems[0] = rowDataItems
                
                var newIndexPaths:[IndexPath] = []
                for i in 0..<results.count {
                    let index = IndexPath.init(row:i , section: 0)
                    newIndexPaths.append(index)
                }
                
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: newIndexPaths)
                }, completion: { (finished) in
                    processCompletion()
                })
            } else {
                sectionItems.append(results)
                collectionView.performBatchUpdates({
                    collectionView.insertSections(IndexSet(integer: 0))
                }, completion: { (finished) in
                    processCompletion()
                })
            }
        }
    }
    
    /// Override to do own stuff after process new data, but do NOT forget to call super
    ///
    /// - Parameters:
    ///   - results: Data processed
    ///   - error: Loading error, nil means succeed
    ///   - isFirstLoad: Whether is first time load operation
    public func didFinishLoadNewData(_ results:[T], _ error:Error?, _ hasMore:Bool, _ isFirstLoad:Bool) {
       
    }
    
    //MARK: Load more
    public func shouldLoadMoreData() -> Bool {
        return self.hasMoreData && !self.isLoadingData()
    }
    
    public func willLoadMoreData() {
        
    }
    
    final func fetchMoreData(_ context:ICBatchFetchingContext? = nil) {
        DispatchQueue.mainSync { [weak self] in
            guard let self = self else {return}

            if !self.shouldLoadMoreData() {
                return
            }
            
            context?.beginBatchFetching()
            
            self.isLoadingMoreData = true
            self.willLoadMoreData()
            self.loadMoreData(isFirstLoad: self.isFirstLoad) { [weak self] (results, error, hasMore) in
                guard let self = self else {return}
                
                context?.completeBatchFetching(true)
                
                self.processLoadMoreDataResult(results, error, self.isFirstLoad)
                DispatchQueue.mainSync { [weak self] in
                    guard let self = self else {return}

                    let isFirstLoad = self.isFirstLoad
                    self.isFirstLoad = false
                    self.hasMoreData = hasMore
                    self.isLoadingMoreData = false
                    self.didFinishLoadMoreData(results, error, hasMore, isFirstLoad)
                }
            }
        }
    }
    
    /// Override to customise your own load more data logic
    ///
    /// - Parameter completion: completion([], nil) means load successfully but no more data, won't call loadMoreData after, You HAVE TO call the completion as soon as you're finished performing that operation
    public func loadMoreData(isFirstLoad:Bool, _ completion:  @escaping (_ results:[T], _ error:Error?, _ hasMore:Bool)->Swift.Void) {
        completion([], nil, false)
    }
    
    
    /// Override to customise loaded data
    ///
    /// - Parameters:
    ///   - results: Data loaded from loadMoreData
    ///   - error:  Loading error, nil means succeed
    ///   - isFirstLoad: Whether is first time load operation
    public func processLoadMoreDataResult(_ results:[T], _ error:Error?, _ isFirstLoad:Bool) {
        guard results.count > 0 else {
            return
        }
        
        DispatchQueue.mainSync { [weak self] in
            guard let self = self else {return}

            if var lastSectionItem = self.sectionItems.last {
                let lastSection = max(0,self.sectionItems.count-1)

                var newIndexPaths:[IndexPath] = []
                let existCount = lastSectionItem.count
                let totalCount = existCount + results.count
                for i in existCount..<totalCount {
                    let index = IndexPath.init(row:i , section: lastSection)
                    newIndexPaths.append(index)
                }
                
                lastSectionItem += results
                
                self.sectionItems[lastSection] = lastSectionItem

                self.collectionView.insertItems(at: newIndexPaths)
            } else {
                self.sectionItems.append(results)
                self.collectionView.insertSections(IndexSet(integer: 0))
            }
        }
    }
    
    /// Override to do own stuff after process more data
    ///
    /// - Parameters:
    ///   - results: Data processed
    ///   - error: Loading error, nil means succeed
    ///   - isFirstLoad: Whether is first time load operation
    public func didFinishLoadMoreData(_ results:[T], _ error:Error?, _ hasMore:Bool, _ isFirstLoad:Bool) {
 
    }
}

//MARK: - DataItem
extension ICCollectionViewController {
    
    public func dataItem(at indexPath:IndexPath) -> T {
        return self.sectionItems[indexPath.section][indexPath.row]
    }
    
    public func appendDataItem(_ item:T) {
        if var last = sectionItems.last {
            last.append(item)
            sectionItems[sectionItems.count-1] = last
        } else {
            sectionItems.append([item])
        }
    }
    
    public func insertDataItem(_ item:T, at indexPath:IndexPath) {
        if sectionItems.count <= 0 {
            appendDataItem(item)
            return
        }
        
        guard indexPath.section >= 0 && indexPath.section < sectionItems.count else {return}
        
        var rowItems = sectionItems[indexPath.section]
        
        guard indexPath.row >= 0 && indexPath.row <= rowItems.count else {return}
        
        rowItems.insert(item, at: indexPath.row)
        sectionItems[indexPath.section] = rowItems
    }
    
    public func replaceDataItem(_ item:T, at indexPath:IndexPath) {
        
        guard indexPath.section >= 0 && indexPath.section < sectionItems.count else {return}
        
        var rowItems = sectionItems[indexPath.section]
        
        guard indexPath.row >= 0 && indexPath.row <= rowItems.count else {return}
        
        rowItems[indexPath.row] = item
        sectionItems[indexPath.section] = rowItems
    }
    
    public func removeDataItem(at indexPath:IndexPath) {
        guard indexPath.section >= 0 && indexPath.section < sectionItems.count else {return}
        
        var rowItems = sectionItems[indexPath.section]
        
        guard indexPath.row >= 0 && indexPath.row <= rowItems.count else {return}
        
        rowItems.remove(at: indexPath.row)
        sectionItems[indexPath.section] = rowItems
    }
    
    public func removeAllDataItems(at section:Int, where shouldBeRemoved: (T) throws -> Bool) {
        guard section >= 0 && section < sectionItems.count else {return}

        var rowItems = sectionItems[section]
        try? rowItems.removeAll(where: shouldBeRemoved)
        sectionItems[section] = rowItems
    }

    public func dataItemCount() -> Int {
        return sectionItems.flatMap({$0}).count
    }
    
    public func sectionCount() -> Int {
        return sectionItems.count
    }
    
    public func sectionItemCount(at section:Int) -> Int {
        if section < 0 || section >= sectionItems.count {
            return 0
        }
        return sectionItems[section].count
    }
    
    public func firstDataItem(where condition: ((T) -> Bool)? = nil) -> T? {
        for i in 0..<sectionItems.count {
            let rows = sectionItems[i]
            
            if let condition = condition {
                for j in 0..<rows.count {
                    if condition(rows[j]) {
                        return rows[j]
                    }
                }
            } else if let first = rows.first {
                return first
            }
        }
        return nil
    }
    
    public func indexPathOfDataItem(where condition: (T) -> Bool) -> IndexPath? {
        for i in 0..<sectionItems.count {
            let rows = sectionItems[i]
            for j in 0..<rows.count {
                if condition(rows[j]) {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
    
    public func lastDataItem(where condition: ((T) -> Bool)? = nil) -> T? {
        
        for i in (0..<sectionItems.count).reversed() {
            let rows = sectionItems[i]
            
            if let condition = condition {
                for j in (0..<rows.count).reversed() {
                    if condition(rows[j]) {
                        return rows[j]
                    }
                }
            } else if let last = rows.last {
                return last
            }
        }
           return nil
    }
}
