//
//  SCImageGridNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/1/26.
//  Copyright © 2019 ivanC. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct ICImageGridConfig {
        // image
    static let imageSizeRatio3_4:CGFloat = 3.0/4.0
    static let imageSizeRatio1_1:CGFloat = 1
    static let imageSizeRatio4_3:CGFloat = 4.0/3.0
    static let imageSizeRatio16_9:CGFloat = 16.0/9.0
    static let imageSizeRatio20_9:CGFloat = 20.0/9.0

    static let imageGap:CGFloat = 2
    static let imageCornerRadius:CGFloat = 4
}

class SCImageGridItemSet {

    var presetImage:UIImage?
    var url:String?

    var imageSize:CGSize {
        if let presetImage = self.presetImage {
            return presetImage.size
        }
        
        return CGSize(1, 1)
    }
        
    init(_ image:UIImage) {
        self.presetImage = image
    }
}

class SCImageGridCell: ASControlNode {
    
    lazy private(set) var imageNode:ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.backgroundColor = .gray
        node.isUserInteractionEnabled = false
        return node
    }()
    
    var dataItem:SCImageGridItemSet {
        didSet {
            reloadImage()
        }
    }
    
    public init(_ dataItem:SCImageGridItemSet) {
        self.dataItem = dataItem
        super.init()
        self.backgroundColor = .clear
        
        self.addSubnode(imageNode)
    }
    
    public func reloadImage() {
        if let presetImage = dataItem.presetImage {
            imageNode.image = presetImage
        } else if let url = dataItem.url, let imageUrl = URL(string: url) {
            imageNode.setURL(imageUrl, resetToDefault: true)
        }
    }
    
    public var roundingCorners:UIRectCorner = [] {
        didSet {
            if roundingCorners.isEmpty {
                imageNode.layer.mask = nil
            } else {
                let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: CGSize(ICImageGridConfig.imageCornerRadius, ICImageGridConfig.imageCornerRadius))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = bounds
                maskLayer.path = path.cgPath
                imageNode.layer.mask = maskLayer
            }
        }
    }
    
    public var isMoving:Bool = false {
        didSet {
            if isMoving {
                shadowColor = UIColor.black.cgColor
                shadowOpacity = 0.2
                shadowRadius = 16
                transform = CATransform3DMakeScale(1.05, 1.05, 1.05)
            } else {
                shadowColor = UIColor.clear.cgColor
                shadowOpacity = 0
                transform = CATransform3DIdentity
            }
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: self.imageNode)
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        reloadImage()
    }
}

protocol SCImageGridNodeDelegate:NSObjectProtocol {
    func imageGridNode(_ imageGridNode:SCImageGridNode, didSelect cell:SCImageGridCell, with item:SCImageGridItemSet, at index:Int)
    
    func imageGridNode(_ imageGridNode:SCImageGridNode, didMoveFrom index:Int, toIndex:Int)
    
    func imageGirdNode(_ imageGridNode:SCImageGridNode, didDelete cell:SCImageGridCell, at index:Int?)

    func imageGirdNode(_ imageGridNode:SCImageGridNode, willBeginInteractiveMovement cell:SCImageGridCell?, at index:Int?)
    func imageGirdNode(_ imageGridNode:SCImageGridNode, didUpdateInteractiveMovement cell:SCImageGridCell?, at index:Int?)
    func imageGirdNode(_ imageGridNode:SCImageGridNode, willEndInteractiveMovement cell:SCImageGridCell?, at index:Int?) -> SCImageGridNode.MovementAction
}

extension SCImageGridNodeDelegate {
    func imageGridNode(_ imageGridNode:SCImageGridNode, didMoveFrom index:Int, toIndex:Int) {
        
    }
    
    func imageGirdNode(_ imageGridNode:SCImageGridNode, didDelete cell:SCImageGridCell, at index:Int?) {
        
    }
    
    func imageGirdNode(_ imageGridNode:SCImageGridNode, willBeginInteractiveMovement cell:SCImageGridCell?, at index:Int?) {
        
    }
    func imageGirdNode(_ imageGridNode:SCImageGridNode, didUpdateInteractiveMovement cell:SCImageGridCell?, at index:Int?) {
        
    }
    func imageGirdNode(_ imageGridNode:SCImageGridNode, willEndInteractiveMovement cell:SCImageGridCell?, at index:Int?) -> SCImageGridNode.MovementAction {
        return .none
    }
}

class SCImageGridNode: ASDisplayNode, ASCollectionDataSource, ASCollectionDelegate {

    public weak var delegate:SCImageGridNodeDelegate?

    override init() {
        super.init()
        
        self.backgroundColor = .clear
        
        self.layer.cornerRadius = ICImageGridConfig.imageCornerRadius
        self.layer.masksToBounds = false
        clipsToBounds = false
    }
    
    //MARK: -
    private var gridCells:[SCImageGridCell] = []

    public func appendGridItem(with items:[SCImageGridItemSet]) {
        
        for item in items {
            let cell = SCImageGridCell(item)
            cell.addTarget(self, action: #selector(gridCellClicked), forControlEvents: .touchUpInside)
            gridCells.append(cell)
        }
        
        updateGridLayout()
    }

    public func setGridItems(_ items:[SCImageGridItemSet]) {
        
        gridCells.forEach({$0.removeFromSupernode()})
        gridCells.removeAll()
        for item in items {
            let cell = SCImageGridCell(item)
            cell.addTarget(self, action: #selector(gridCellClicked), forControlEvents: .touchUpInside)
            gridCells.append(cell)
        }
        
        updateGridLayout()
    }
    
    public var gridCellCount:Int {
        return gridCells.count
    }
    
    public func gridCell(at index:Int) -> SCImageGridCell? {
        if index < 0 || index >= gridCells.count {
            return nil
        }
        return gridCells[index]
    }
    
    public func gridCell(at pos:CGPoint) -> SCImageGridCell? {
        
        for cell in gridCells {
            if cell.frame.contains(pos) {
                return cell
            }
        }
        return nil
    }
    
    public func gridCellFrame(at index:Int, toView:UIView) -> CGRect? {
        if let cell = gridCell(at: index) {
            return view.convert(cell.frame, to: toView)
        }
        return nil
    }
    
    internal func reloadGridCells() {
        gridCells.forEach({$0.reloadImage()})
    }
    
    //MARK: - Actions
    @objc private func gridCellClicked(_ sender:SCImageGridCell) {
        if let index = gridCells.firstIndex(of: sender) {
            self.delegate?.imageGridNode(self, didSelect: sender, with: sender.dataItem, at: index)
       }
    }

    //MARK: - Gesture
    public enum MovementAction {
        case none
        case delete
    }
    
    public var canMoveItem:Bool = false
    private var isMovingItem:Bool = false
    
    override func didLoad() {
        super.didLoad()
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized)))
    }
    
    private var movingCell:SCImageGridCell?
    private var movingCellSourceIndex:Int?
    private var movingCellDestinationIndex:Int?
    
    private var fixPosOffset:CGPoint = .zero
    private func beginInteractiveMovementForItem(from pos:CGPoint) -> SCImageGridCell? {
        fixPosOffset = .zero
        if let cell = gridCell(at: pos) {
            if cell.view.superview != nil {
                let posInCell = self.view.convert(pos, to: cell.view)
                fixPosOffset = CGPoint(posInCell.x - cell.bounds.midX, posInCell.y - cell.bounds.midY)
            }
            return cell
        }
        return nil
    }
    
    private func updateInteractiveMovementTargetPosition(from pos:CGPoint) {
        guard let cell = movingCell else {return}

        let fixPos = CGPoint(pos.x - fixPosOffset.x, pos.y - fixPosOffset.y)
        cell.frame.origin = CGPoint(fixPos.x - cell.bounds.midX, fixPos.y - cell.bounds.midY)
        
        for i in 0..<gridCells.count {
            let otherCell = gridCells[i]
            if cell != otherCell {
                
                if otherCell.frame.contains(fixPos) {
                    
                    if let index = gridCells.firstIndex(of: cell) {
                        gridCells.remove(at: index)
                        gridCells.insert(cell, at: i)
                        
                        movingCellDestinationIndex = i
                        
                        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                            self.relayoutCells(ignoreIndex: i)
                        }) { (finished) in
                            
                        }
                    }
                    break
                }
            }
        }
        
        delegate?.imageGirdNode(self, didUpdateInteractiveMovement: cell, at: movingCellSourceIndex)
    }
    
    private func endInteractiveMovement() {
        
        let action = delegate?.imageGirdNode(self, willEndInteractiveMovement: movingCell, at: movingCellSourceIndex)
        if action == .delete {
            if let cell = movingCell, let index = gridCells.firstIndex(of: cell) {
                cell.removeFromSupernode()
                gridCells.remove(at: index)
                updateGridLayout()
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.relayoutCells()
                }) { [weak self] (finished) in
                    guard let self = self else {return}
                    self.delegate?.imageGirdNode(self, didDelete: cell, at: self.movingCellSourceIndex)
                    self.resetMovement()
                }
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                self.movingCell?.isMoving = false
                self.isMovingItem = false
                self.relayoutCells()
            }) { [weak self] (finished) in
                guard let self = self else {return}
                if let source = self.movingCellSourceIndex, let dest = self.movingCellDestinationIndex, source != dest {
                    self.delegate?.imageGridNode(self, didMoveFrom: source, toIndex: dest)
                }
                
                self.resetMovement()
            }
        }
    }
    
    private func resetMovement() {
        movingCellSourceIndex = nil
        movingCellDestinationIndex = nil
        movingCell = nil
        
        isMovingItem = false
    }
    
    @objc private func longPressGestureRecognized(_ gesture:UILongPressGestureRecognizer) {
        guard canMoveItem else {
            return
        }
        
        let pos = gesture.location(in: self.view)
        switch gesture.state {
        case .began:
            if let cell = beginInteractiveMovementForItem(from: pos) {
                view.bringSubviewToFront(cell.view)
                cell.isMoving = true
                movingCell = cell
                movingCellSourceIndex = gridCells.firstIndex(of: cell)
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    // Fallback on earlier versions
                }
                isMovingItem = true
                
                delegate?.imageGirdNode(self, willBeginInteractiveMovement: movingCell, at: movingCellSourceIndex)
            }
            break
        case .changed:
            updateInteractiveMovementTargetPosition(from: pos)
            break
        default:
            endInteractiveMovement()
            break
        }
    }
    
    //MARK: - layout
    internal let itemSpacing:CGFloat = ICImageGridConfig.imageGap
    internal let lineSpacing:CGFloat = ICImageGridConfig.imageGap
    internal let maxRowItemCount = 3
    internal var itemSize:CGSize = .zero

    public var gridMaxWidth:CGFloat = 0 {
        didSet {
            updateGridLayout()
        }
    }
    
    private func updateGridLayout() {
        guard gridMaxWidth > 0 else {return}
        
        let oneItemSize = max(0,floor((gridMaxWidth - itemSpacing*2.0) / 3.0))
        var maxWidth = oneItemSize * CGFloat(maxRowItemCount) + itemSpacing*2.0
        
        var gridHeight:CGFloat = 0
        let count = gridCells.count
        
        if count == 0 {
            
        } else if count == 1 {
            
            var ratio:CGFloat = 1
            var width:CGFloat = oneItemSize*2 + itemSpacing
            var height = width
            
            let imageItemSet = gridCells[0].dataItem
            if true {
                
                let imageSize = imageItemSet.imageSize
                if imageSize.width > 0 && imageSize.height > 0 {
                    ratio = imageSize.width/imageSize.height
                }
                
                let mid34_11 = (ICImageGridConfig.imageSizeRatio1_1 - ICImageGridConfig.imageSizeRatio3_4)/2.0 + ICImageGridConfig.imageSizeRatio3_4
                let mid11_43 = (ICImageGridConfig.imageSizeRatio4_3 - ICImageGridConfig.imageSizeRatio1_1)/2.0 + ICImageGridConfig.imageSizeRatio1_1
                let mid43_169 = (ICImageGridConfig.imageSizeRatio16_9 - ICImageGridConfig.imageSizeRatio4_3)/2.0 + ICImageGridConfig.imageSizeRatio4_3
                
                if ratio < mid34_11 {
                    height = width/ICImageGridConfig.imageSizeRatio3_4
                } else if ratio >= mid11_43 && ratio <= mid43_169 {
                    width = maxWidth
                    height = width/ICImageGridConfig.imageSizeRatio4_3
                }
                else if ratio > mid43_169 {
                    width = maxWidth
                    height = width/ICImageGridConfig.imageSizeRatio16_9
                }
            }
            
            itemSize = CGSize(width, height)
            gridHeight = height
            maxWidth = width
        } else if count == 2 || count == 4 {
            let width = oneItemSize
            itemSize = CGSize(oneItemSize, oneItemSize)
            
            let lineCount = count/2
            gridHeight = width * CGFloat(lineCount) + CGFloat(lineCount - 1) * itemSpacing
            maxWidth = width*2 + itemSpacing
        } else {
            let width = oneItemSize
            itemSize = CGSize(width, width)
            
            let lineCount = ceil(Float(count)/3.0)
            gridHeight = width * CGFloat(lineCount) + CGFloat(lineCount - 1) * itemSpacing
        }
        
        style.preferredSize = CGSize(maxWidth, gridHeight)
        setNeedsLayout()
    }
    
    private func relayoutCells(ignoreIndex:Int = -1) {
        guard gridMaxWidth > 0, itemSize.width > 0 else {return}

        let count = gridCells.count
        var lineIndex = 0
        
        // Layout all cell
        var origin:CGPoint = .zero
        for i in 0..<count {
            
            let cell = gridCells[i]
            if i != ignoreIndex {
                cell.frame.origin = origin
            }
            cell.frame.size = itemSize

            origin.x += itemSize.width + itemSpacing
            if origin.x > style.preferredSize.width {
                origin.y += itemSize.height + lineSpacing
                origin.x = 0
                
                if i != count - 1 {
                    lineIndex += 1
                }
            }
        }
        
        // Make last cell special
        if  let lastCell = gridCells.last {
            if gridCells.count == 5 || gridCells.count == 8 {
                lastCell.frame.size.width = itemSize.width*2 + itemSpacing
            } else if gridCells.count == 7 {
                lastCell.frame.size.width = style.preferredSize.width
            }
        }
        
        // Make round corners
        gridCells.forEach({$0.roundingCorners = []})
        if count == 1 {
            gridCells[0].roundingCorners = [.allCorners]
        } else if count == 2 {
            gridCells[0].roundingCorners = [.topLeft, .bottomLeft]
            gridCells[1].roundingCorners = [.topRight, .bottomRight]
        } else if count == 3 {
            gridCells[0].roundingCorners = [.topLeft, .bottomLeft]
            gridCells[2].roundingCorners = [.topRight, .bottomRight]
        } else if count == 4 {
            gridCells[0].roundingCorners = [.topLeft]
            gridCells[1].roundingCorners = [.topRight]
            gridCells[2].roundingCorners = [.bottomLeft]
            gridCells[3].roundingCorners = [.bottomRight]
        } else if count > 0 {
            gridCells[0].roundingCorners = [.topLeft]
            gridCells[2].roundingCorners = [.topRight]

            let bottomLeftIndex = maxRowItemCount * lineIndex
            if bottomLeftIndex < 0 || bottomLeftIndex >= count {
                assert(false)
            } else if bottomLeftIndex == count - 1 {
                gridCells[bottomLeftIndex].roundingCorners = [.bottomLeft, .bottomRight]
            } else {
                gridCells[bottomLeftIndex].roundingCorners = [.bottomLeft]
                gridCells[count-1].roundingCorners = [.bottomRight]
            }
        }
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if isMovingItem {
            return
        }
        
        gridCells.forEach({
            if $0.supernode != self {
                addSubnode($0)
            }
        })
        
        relayoutCells()
    }
}
