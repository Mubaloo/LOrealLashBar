//
//  PeakedCarouselLayout.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 Arranges cells in a horizontal line, calculating an additional 'highlight' variable that 
 depends upon how close a cell is to the centre of the view. Also performs various calculations
 used to keep the brush carousel and the category carousel aligned.
 */

class HighlightCarouselLayout: UICollectionViewLayout {
    
    /** The distance between cells */
    var spacing: CGFloat = 150
    
    /** The size of each cell, at maximum on-screen size */
    var cellSize: CGSize = CGSize(width: 192, height: 768)
    
    /** The index path currently closest to the centre of the view */
    var midIndex: IndexPath? { get { return _midIndex } }
    fileprivate var _midIndex: IndexPath?
    
    /** 
     The amount of offset from the middle of the screen to the most central cell. This is
     used to keep the category names aligned neatly under the last / first cells in their
     associated section when scrolling.
     */
    var midSectionOffset: CGFloat { get { return _midSectionOffset } }
    fileprivate var _midSectionOffset: CGFloat = 0
    
    fileprivate var contentSize = CGSize.zero
    fileprivate var sectionStarts = [Int]()
    fileprivate var lastIndex = 0
    
    fileprivate var halfWidth: CGFloat = 0
    fileprivate var midPoint: CGFloat = 0
    
    // Pre-calculations used when simulating an infinite scroll area, cached for speed.
    
    fileprivate var _oneThird: CGFloat = 0
    fileprivate var _oneHalf: CGFloat = 0
    fileprivate var _twoThirds: CGFloat = 0
    
    var oneThird: CGFloat { get { return _oneThird } }
    var oneHalf: CGFloat { get { return _oneHalf } }
    var twoThirds: CGFloat { get { return _twoThirds } }
    
    override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds != collectionView?.bounds
    }
    
    override class var layoutAttributesClass : AnyClass {
        return HighlightLayoutAttributes.self
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        // Precalculate a few values
        halfWidth = collectionView.frame.width / 2
        midPoint = collectionView.contentOffset.x + halfWidth
        let mainAbsolute = absoluteIndexForCellAtXPos(midPoint)
        _midIndex = overallIndexToIndexPath(mainAbsolute)
        
        // If the central item is the first or last in its section, calculate midsection offset.
        if let midIndex = _midIndex {
            let itemCount = collectionView.numberOfItems(inSection: (midIndex as NSIndexPath).section)
            switch (midIndex as NSIndexPath).item {
            case 0:
                let offset = xPosForCellAtAbsoluteIndex(mainAbsolute) - midPoint
                _midSectionOffset = (itemCount > 1 && offset < 0) ? 0 : offset
            case itemCount - 1:
                let offset = xPosForCellAtAbsoluteIndex(mainAbsolute) - midPoint
                _midSectionOffset = (itemCount > 1 && offset > 0) ? 0 : offset
            default :
                _midSectionOffset = 0
            }
        }
        
        // Record the absolute order at which each section starts
        sectionStarts.removeAll()
        var total = 0
        
        let sectionCount = collectionView.numberOfSections
        for section in 0 ..< sectionCount {
            sectionStarts.append(total)
            let itemCount = collectionView.numberOfItems(inSection: section)
            total += itemCount
        }
        
        // Precalculate required values that are reliant upon content size
        let width = spacing * CGFloat(total)
        contentSize = CGSize(width: width, height: collectionView.frame.height)
        _oneThird = width / 3
        _oneHalf = width * 0.5
        _twoThirds = _oneThird * 2
        
        lastIndex = total-1
    }
    
    // MARK:- Utility Functions
    
    func indexPathForCellAtXPos(_ position: CGFloat) -> IndexPath? {
        let absolute = absoluteIndexForCellAtXPos(position)
        return overallIndexToIndexPath(absolute)
    }
    
    fileprivate func xPosForCellAtAbsoluteIndex(_ index: Int) -> CGFloat {
        return spacing * CGFloat(index)
    }
    
    fileprivate func absoluteIndexForCellAtXPos(_ xPos: CGFloat) -> Int {
        return Int(round(xPos / spacing))
    }
    
    /**
     Returns the X position of the cell closest to the passed position.
     Used when determining where the scroll view should stop
     */
    func snapXPositionToCell(_ position: CGFloat) -> CGFloat {
        let index = absoluteIndexForCellAtXPos(position)
        let previous = xPosForCellAtAbsoluteIndex(index)
        if position - previous < (spacing + cellSize.width) / 2 { return previous }
        return xPosForCellAtAbsoluteIndex(index+1)
    }
    
    /**
     Returns the amount of offset required to center the given section in
     the middle of the view. Used to keep section titles aligned with brush cells.
     */
    func contentOffsetToCenterSection(_ section: Int) -> CGFloat {
        guard let collectionView = collectionView,
            let absolute = indexPathToOverallIndex(IndexPath(item: 0, section: section))
            else { return 0 }
        
        let xPos = xPosForCellAtAbsoluteIndex(absolute)
        return xPos - collectionView.frame.width / 2
    }
    
    /**
     Converts an index path into its absolute position in the list of all sections.
     */
    fileprivate func indexPathToOverallIndex(_ indexPath: IndexPath) -> Int? {
        if sectionStarts.count <= (indexPath as NSIndexPath).section { return nil }
        return sectionStarts[(indexPath as NSIndexPath).section] + (indexPath as NSIndexPath).item
    }
    
    /**
     Returns the index path for the cell in the Nth position, taking all sections into account.
     */
    fileprivate func overallIndexToIndexPath(_ index: Int) -> IndexPath? {
        guard let first = sectionStarts.filter({ $0 <= index }).last,
            let section = sectionStarts.index(of: first)
            , index >= first
            else { return nil }
        
        return IndexPath(item: index - first, section: section)
    }
    
    /**
     Returns an array of index paths between those given, inclusive. Can bridge different sections.
    */
    fileprivate func indexPathsInRange(_ from: IndexPath, to: IndexPath) -> [IndexPath] {
        guard let collectionView = collectionView else { return [] }
        
        var allIndices = [IndexPath]()
        for section in (from as NSIndexPath).section ... (to as NSIndexPath).section {
            let itemCount = collectionView.numberOfItems(inSection: section)
            let fromItem = (section == (from as NSIndexPath).section) ? (from as NSIndexPath).item : 0
            let toItem = (section == (to as NSIndexPath).section) ? (to as NSIndexPath).item : itemCount-1
            for item in fromItem ... toItem {
                allIndices.append(IndexPath(item: item, section: section))
            }
        }
        return allIndices
    }
    
    // MARK:- Cell Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let minX = max(Int(floor(rect.minX / CGFloat(spacing))) - 1, 0)
        let maxX = min(Int(ceil(rect.maxX / CGFloat(spacing))) + 1, lastIndex)
        
        guard let fromIP = overallIndexToIndexPath(minX),
            let toIP = overallIndexToIndexPath(maxX)
            else { return nil }
        
        return indexPathsInRange(fromIP, to: toIP).map({
            layoutAttributesForItem(at: $0)!
        })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let index = indexPathToOverallIndex(indexPath) else { return nil }
        
        let xPos = xPosForCellAtAbsoluteIndex(index)
        let yPos = (contentSize.height - cellSize.height) / 2
        
        let difference = fabs(midPoint - xPos)
        let fromRange = FloatRange(start: 0, end: 1)
        let scaleAdjust = Float(1 - sin(difference / halfWidth))
        let scale = CGFloat(scaleAdjust.normalise(fromRange, toRange: FloatRange(start: 0.5, end: 1)))
        
        let attr = HighlightLayoutAttributes(forCellWith: indexPath)
        attr.frame = CGRect(origin: CGPoint(x: xPos - cellSize.width / 2, y: yPos), size: cellSize)
        attr.highlight = 1 - (difference / spacing)
        attr.transform = CGAffineTransform(scaleX: scale, y: scale)
        return attr
    }
    
}
