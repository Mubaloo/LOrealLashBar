//
//  InterspacedImageLayout.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 A simple form of layout that arranges cells in a vertical stack with a decoration view
 interspersed between them.
 */

class InterspacedImageLayout: UICollectionViewLayout {
    
    /** The size of each cell */
    var cellSize = CGSize(width: 650, height: 182) { didSet { invalidateLayout() } }
    
    /** The size of the decoration views between the cells */
    var interspaceSize = CGSize(width: 8, height: 11) { didSet { invalidateLayout() } }
    
    /** The amount of spacing between cells. Decorations are interspersed between these evenly. */
    var spacing: CGFloat = 60 { didSet { invalidateLayout() } }
    
    private var cellX: CGFloat = 0
    private var interspaceX: CGFloat = 0
    private var contentSize = CGSize.zero
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.size.width
    }
    
    override func prepareLayout() {
        guard let collectionView = collectionView else { return }
        let height = CGFloat(collectionView.numberOfItemsInSection(0)) * (cellSize.height + spacing) + spacing
        contentSize = CGSize(width: collectionView.bounds.width, height: height)
        cellX = (collectionView.bounds.width - cellSize.width) / 2
        interspaceX = (collectionView.bounds.width - interspaceSize.width) / 2
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        let maxItem = collectionView.numberOfItemsInSection(0)-1
        let minimum = max(0, Int(floor(rect.minX / (cellSize.height + spacing))))
        let maximum = max(maxItem, Int(ceil(rect.maxX / (cellSize.height + spacing))))
        
        var cellAttr = (minimum ... maximum).map({
            layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: $0, inSection: 0))!
        })
        
        if minimum == maximum { return cellAttr }
        
        let decorationAttr = (minimum ... maximum-1).map({
            layoutAttributesForDecorationViewOfKind("Separator", atIndexPath: NSIndexPath(forItem: $0, inSection: 0))!
        })
        
        cellAttr.appendContentsOf(decorationAttr)
        return cellAttr
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let yPos = (cellSize.height + spacing) * CGFloat(indexPath.row) + spacing
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = CGRect(x: cellX, y: yPos, width: cellSize.width, height: cellSize.height)
        attr.zIndex = 10
        return attr
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let yPos = (cellSize.height + spacing) * CGFloat(indexPath.row + 1) - ((spacing + interspaceSize.height) / 2) + spacing
        let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, withIndexPath: indexPath)
        attr.frame = CGRect(x: interspaceX, y: yPos, width: interspaceSize.width, height: interspaceSize.height)
        return attr
    }
    
}