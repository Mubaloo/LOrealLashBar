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
    
    fileprivate var cellX: CGFloat = 0
    fileprivate var interspaceX: CGFloat = 0
    fileprivate var contentSize = CGSize.zero
    
    override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.size.width
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        let height = CGFloat(collectionView.numberOfItems(inSection: 0)) * (cellSize.height + spacing) + spacing
        contentSize = CGSize(width: collectionView.bounds.width, height: height)
        cellX = (collectionView.bounds.width - cellSize.width) / 2
        interspaceX = (collectionView.bounds.width - interspaceSize.width) / 2
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        let maxItem = collectionView.numberOfItems(inSection: 0)-1
        let minimum = max(0, Int(floor(rect.minX / (cellSize.height + spacing))))
        let maximum = max(maxItem, Int(ceil(rect.maxX / (cellSize.height + spacing))))
        
        var cellAttr = (minimum ... maximum).map({
            layoutAttributesForItem(at: IndexPath(item: $0, section: 0))!
        })
        
        if minimum == maximum { return cellAttr }
        
        let decorationAttr = (minimum ... maximum-1).map({
            layoutAttributesForDecorationView(ofKind: "Separator", at: IndexPath(item: $0, section: 0))!
        })
        
        cellAttr.append(contentsOf: decorationAttr)
        return cellAttr
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let yPos = (cellSize.height + spacing) * CGFloat((indexPath as NSIndexPath).row) + spacing
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.frame = CGRect(x: cellX, y: yPos, width: cellSize.width, height: cellSize.height)
        attr.zIndex = 10
        return attr
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let yPos = (cellSize.height + spacing) * CGFloat((indexPath as NSIndexPath).row + 1) - ((spacing + interspaceSize.height) / 2) + spacing
        let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        attr.frame = CGRect(x: interspaceX, y: yPos, width: interspaceSize.width, height: interspaceSize.height)
        return attr
    }
    
}
