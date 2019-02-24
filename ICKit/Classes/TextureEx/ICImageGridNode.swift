//
//  SCImageGridNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/1/26.
//  Copyright © 2019 ivanC. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct SCImageGridItem {
    var url:String?
    var image:UIImage?
    var size:CGSize = .zero
    
    init(_ image:UIImage) {
        self.image = image
        self.size = image.size
    }
    
    init (_ url:String) {
        self.url = url
    }
}

class SCImageGridCell: ASCellNode {
    lazy private(set) var imageNode:ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.backgroundColor = .lightGray
//        node.layer.cornerRadius = Flow.imageCornerRadius
        node.isUserInteractionEnabled = false
        return node
    }()
    
    override init() {
        super.init()
        self.backgroundColor = .clear
        
        self.addSubnode(imageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: self.imageNode)
    }
}

protocol SCImageGridNodeDelegate:NSObjectProtocol {
    func imageGridNode(_ imageGridNode:SCImageGridNode, didSelect cell:SCImageGridCell, with item:SCImageGridItem, at index:IndexPath)
    
    func imageGridNode(_ imageGridNode:SCImageGridNode, didMoveFrom index:IndexPath, toIndex:IndexPath)
    
}

extension SCImageGridNodeDelegate {
    func imageGridNode(_ imageGridNode:SCImageGridNode, didMoveFrom index:IndexPath, toIndex:IndexPath) {
        
    }
}

class SCImageGridNode: ASDisplayNode, ASCollectionDataSource, ASCollectionDelegate {
    
    public weak var delegate:SCImageGridNodeDelegate?
    public var disableReload:Bool = false
    lazy private(set) var collectionNode:ASCollectionNode = {
        let node = ASCollectionNode(collectionViewLayout: self.gridLayout)
        node.backgroundColor = .clear
        node.dataSource = self
        node.delegate = self
        node.showsVerticalScrollIndicator = false
        node.showsHorizontalScrollIndicator = false
        return node
    }()
    
    public var canMoveItem:Bool = false
    private var isMovingItem:Bool = false
    
    private let itemSpacing:CGFloat = Flow.imageGap
    lazy private var gridLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = self.itemSpacing
        layout.minimumInteritemSpacing = self.itemSpacing
        return layout
    }()
    
    private(set) var imageItems:[SCImageGridItem] = []
    
    override init() {
        super.init()
        
        self.backgroundColor = .clear
        self.addSubnode(self.collectionNode)
        
        self.layer.cornerRadius = Flow.imageCornerRadius
        self.layer.masksToBounds = true
    }
    
    public func reloadGrid(images:[SCImageGridItem]) {
        
        self.imageItems.removeAll()
        self.imageItems += images
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    //MARK: - Collection
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.imageItems.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        return SCImageGridCell()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        guard let cell = node as? SCImageGridCell else {
            return
        }
        
        guard let indexPath = cell.indexPath else {
            return
        }
        
        let imageItem = self.imageItems[indexPath.row]
        if let imageUrl = imageItem.url {
            cell.imageNode.setImageURL(URL(string: imageUrl), resetToDefault: false)
        } else if let presetImage = imageItem.image {
            cell.imageNode.image = presetImage
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard let cellNode = collectionNode.nodeForItem(at: indexPath) as? SCImageGridCell else {
            return
        }
        
        self.delegate?.imageGridNode(self, didSelect: cellNode, with: self.imageItems[indexPath.row], at: indexPath)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, canMoveItemWith node: ASCellNode) -> Bool {
        return self.canMoveItem
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = self.imageItems[sourceIndexPath.row]
        self.imageItems.remove(at: sourceIndexPath.row)
        self.imageItems.insert(item, at: destinationIndexPath.row)
        
        self.delegate?.imageGridNode(self, didMoveFrom: sourceIndexPath, toIndex: destinationIndexPath)
    }
    
    //MARK: - Gesture
    override func didLoad() {
        super.didLoad()
        
        self.collectionNode.view.isScrollEnabled = false
        self.collectionNode.view.backgroundColor = .clear
        self.collectionNode.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized)))
    }
    
    @objc private func longPressGestureRecognized(_ gesture:UILongPressGestureRecognizer) {
        
        guard self.canMoveItem else {
            return
        }
        
        let pos = gesture.location(in: self.collectionNode.view)
        
        switch gesture.state {
        case .began:
            if let indexPath = self.collectionNode.indexPathForItem(at: pos) {
                self.isMovingItem = self.collectionNode.view.beginInteractiveMovementForItem(at: indexPath)
            }
            break
        case .changed:
            if self.isMovingItem {
                self.collectionNode.view.updateInteractiveMovementTargetPosition(pos)
            }
            break
        case .ended:
            if self.isMovingItem {
                self.isMovingItem = false
                self.collectionNode.view.endInteractiveMovement()
            }
            break
        default:
            if self.isMovingItem {
                self.isMovingItem = false
                self.collectionNode.view.cancelInteractiveMovement()
            }
            break
        }
    }
    
    //MARK: - layout
    private func relayoutCollection() {
        guard !disableReload else {return}
        self.collectionNode.collectionViewLayout = self.gridLayout
        self.collectionNode.reloadDataWitoutAnimation()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var maxWidth = constrainedSize.max.width
        

        var gridHeight:CGFloat = 0
        let count = self.imageItems.count
        
        if count == 0 {
            
        } else if count == 1 {
            let imageItem = self.imageItems[0]
            
            var ratio:CGFloat = 1
            var width:CGFloat = floor(maxWidth * 2.0 / 3.0)
            var height = width
            if imageItem.size.width > 0 && imageItem.size.height > 0 {
                ratio = imageItem.size.width/imageItem.size.height
            }
            
            let mid34_11 = (Flow.imageSizeRatio1_1 - Flow.imageSizeRatio3_4)/2.0 + Flow.imageSizeRatio3_4
            let mid11_43 = (Flow.imageSizeRatio4_3 - Flow.imageSizeRatio1_1)/2.0 + Flow.imageSizeRatio1_1
            let mid43_169 = (Flow.imageSizeRatio16_9 - Flow.imageSizeRatio4_3)/2.0 + Flow.imageSizeRatio4_3

            if ratio < mid34_11 {
                height = width/Flow.imageSizeRatio3_4
            } else if ratio >= mid11_43 && ratio <= mid43_169 {
                width = height * Flow.imageSizeRatio4_3
            } else if ratio > mid43_169 {
                width = maxWidth
                height = width/Flow.imageSizeRatio16_9
            }
            
            self.gridLayout.itemSize = CGSize(width, height)
            gridHeight = height
            maxWidth = width
        } else if count == 2 || count == 4 {
            let width = floor((maxWidth - self.itemSpacing) / 2.0)
            self.gridLayout.itemSize = CGSize(width, width)
            
            let lineCount = count/2
            gridHeight = width * CGFloat(lineCount) + CGFloat(lineCount - 1) * self.itemSpacing
        } else {
            let width = floor((maxWidth - self.itemSpacing*2.0) / 3.0)
            self.gridLayout.itemSize = CGSize(width, width)
            
            let lineCount = ceil(Float(count)/3.0)
            gridHeight = width * CGFloat(lineCount) + CGFloat(lineCount - 1) * self.itemSpacing
        }
        
        DispatchQueue.main.async {
            self.relayoutCollection()
        }
//
        self.collectionNode.style.preferredSize = CGSize(maxWidth, gridHeight)
        return ASStackLayoutSpec.init(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .center, children: [collectionNode])
    }
}
