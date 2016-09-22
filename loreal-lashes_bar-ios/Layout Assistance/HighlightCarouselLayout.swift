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
    var midIndex: NSIndexPath? { get { return _midIndex } }
    private var _midIndex: NSIndexPath?
    
    /** 
     The amount of offset from the middle of the screen to the most central cell. This is
     used to keep the category names aligned neatly under the last / first cells in their
     associated section when scrolling.
     */
    var midSectionOffset: CGFloat { get { return _midSectionOffset } }
    private var _midSectionOffset: CGFloat = 0
    
    private var contentSize = CGSize.zero
    private var sectionStarts = [Int]()
    private var lastIndex = 0
    
    private var halfWidth: CGFloat = 0
    private var midPoint: CGFloat = 0
    
    // Pre-calculations used when simulating an infinite scroll area, cached for speed.
    
    private var _oneThird: CGFloat = 0
    private var _oneHalf: CGFloat = 0
    private var _twoThirds: CGFloat = 0
    
    var oneThird: CGFloat { get { return _oneThird } }
    var oneHalf: CGFloat { get { return _oneHalf } }
    var twoThirds: CGFloat { get { return _twoThirds } }
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return newBounds != collectionView?.bounds
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return HighlightLayoutAttributes.self
    }
    
    override func prepareLayout() {
        guard let collectionView = collectionView else { return }
        
        // Precalculate a few values
        halfWidth = collectionView.frame.width / 2
        midPoint = collectionView.contentOffset.x + halfWidth
        let mainAbsolute = absoluteIndexForCellAtXPos(midPoint)
        _midIndex = overallIndexToIndexPath(mainAbsolute)
        
        // If the central item is the first or last in its section, calculate midsection offset.
        if let midIndex = _midIndex {
            let itemCount = collectionView.numberOfItemsInSection(midIndex.section)
            switch midIndex.item {
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
        
        let sectionCount = collectionView.numberOfSections()
        for section in 0 ..< sectionCount {
            sectionStarts.append(total)
            let itemCount = collectionView.numberOfItemsInSection(section)
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
    
    func indexPathForCellAtXPos(position: CGFloat) -> NSIndexPath? {
        let absolute = absoluteIndexForCellAtXPos(position)
        return overallIndexToIndexPath(absolute)
    }
    
    private func xPosForCellAtAbsoluteIndex(index: Int) -> CGFloat {
        return spacing * CGFloat(index)
    }
    
    private func absoluteIndexForCellAtXPos(xPos: CGFloat) -> Int {
        return Int(round(xPos / spacing))
    }
    
    /**
     Returns the X position of the cell closest to the passed position.
     Used when determining where the scroll view should stop
     */
    func snapXPositionToCell(position: CGFloat) -> CGFloat {
        let index = absoluteIndexForCellAtXPos(position)
        let previous = xPosForCellAtAbsoluteIndex(index)
        if position - previous < (spacing + cellSize.width) / 2 { return previous }
        return xPosForCellAtAbsoluteIndex(index+1)
    }
    
    /**
     Returns the amount of offset required to center the given section in
     the middle of the view. Used to keep section titles aligned with brush cells.
     */
    func contentOffsetToCenterSection(section: Int) -> CGFloat {
        guard let collectionView = collectionView,
            absolute = indexPathToOverallIndex(NSIndexPath(forItem: 0, inSection: section))
            else { return 0 }
        
        let xPos = xPosForCellAtAbsoluteIndex(absolute)
        return xPos - collectionView.frame.width / 2
    }
    
    /**
     Converts an index path into its absolute position in the list of all sections.
     */
    private func indexPathToOverallIndex(indexPath: NSIndexPath) -> Int? {
        if sectionStarts.count <= indexPath.section { return nil }
        return sectionStarts[indexPath.section] + indexPath.item
    }
    
    /**
     Returns the index path for the cell in the Nth position, taking all sections into account.
     */
    private func overallIndexToIndexPath(index: Int) -> NSIndexPath? {
        guard let first = sectionStarts.filter({ $0 <= index }).last,
            section = sectionStarts.indexOf(first)
            where index >= first
            else { return nil }
        
        return NSIndexPath(forItem: index - first, inSection: section)
    }
    
    /**
     Returns an array of index paths between those given, inclusive. Can bridge different sections.
    */
    private func indexPathsInRange(from: NSIndexPath, to: NSIndexPath) -> [NSIndexPath] {
        guard let collectionView = collectionView else { return [] }
        
        var allIndices = [NSIndexPath]()
        for section in from.section ... to.section {
            let itemCount = collectionView.numberOfItemsInSection(section)
            let fromItem = (section == from.section) ? from.item : 0
            let toItem = (section == to.section) ? to.item : itemCount-1
            for item in fromItem ... toItem {
                allIndices.append(NSIndexPath(forItem: item, inSection: section))
            }
        }
        return allIndices
    }
    
    // MARK:- Cell Attributes
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let minX = max(Int(floor(rect.minX / CGFloat(spacing))) - 1, 0)
        let maxX = min(Int(ceil(rect.maxX / CGFloat(spacing))) + 1, lastIndex)
        
        guard let fromIP = overallIndexToIndexPath(minX),
            toIP = overallIndexToIndexPath(maxX)
            else { return nil }
        
        return indexPathsInRange(fromIP, to: toIP).map({
            layoutAttributesForItemAtIndexPath($0)!
        })
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let index = indexPathToOverallIndex(indexPath) else { return nil }
        
        let xPos = xPosForCellAtAbsoluteIndex(index)
        let yPos = (contentSize.height - cellSize.height) / 2
        
        let difference = fabs(midPoint - xPos)
        let fromRange = FloatRange(start: 0, end: 1)
        let scaleAdjust = Float(1 - sin(difference / halfWidth))
        let scale = CGFloat(scaleAdjust.normalise(fromRange, toRange: FloatRange(start: 0.5, end: 1)))
        
        let attr = HighlightLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = CGRect(origin: CGPoint(x: xPos - cellSize.width / 2, y: yPos), size: cellSize)
        attr.highlight = 1 - (difference / spacing)
        attr.transform = CGAffineTransformMakeScale(scale, scale)
        return attr
    }
    
}
