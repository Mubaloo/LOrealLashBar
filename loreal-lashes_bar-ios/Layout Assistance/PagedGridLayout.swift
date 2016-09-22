//
//  PagedGridLayout.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 25/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 A layout that arranges its cells in a grid with horizontal pages. Note that this especially
 permits different spacing between cells on a page, and between individual pages, without
 requiring them to be arranged in sections. Distances between cells are inferred from the
 size of the collection view and the amount of page inset.
 */

class PagedGridLayout: UICollectionViewLayout {
    
    /** The number of rows of cells on a page. */
    var rowsPerPage = 2
    
    /** The number of columns of cells on a page. */
    var columnsPerPage = 2
    
    /** The distances from the edge of all the cells on a page to the edge of the view */
    var pageInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
    
    /** The size of each individual cell. */
    var cellSize = CGSize(width: 308, height: 252)
    
    // Precalculated layout variables
    
    private var spacing = CGSize.zero
    private var itemsPerPage = 0
    private var sectionStartPages = [Int]()
    private var contentSize = CGSize.zero
    
    private var _pageCount: Int = 0
    var pageCount: Int { get { return _pageCount } }
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize
    }
    
    func pageForIndexPath(indexPath: NSIndexPath) -> Int {
        let firstPage = sectionStartPages[indexPath.section]
        return firstPage + Int(floor(Float(indexPath.item)/Float(itemsPerPage)))
    }
    
    override func prepareLayout() {
        guard let collectionView = collectionView else { return }
        
        // Precalculate the spacing between cells
        let fRow = CGFloat(rowsPerPage)
        let fColumn = CGFloat(columnsPerPage)
        let pageWidth = (collectionView.frame.width - pageInsets.left - pageInsets.right)
        let pageHeight = (collectionView.frame.height - pageInsets.top - pageInsets.bottom)
        let spaceX = (pageWidth - fColumn * cellSize.width) / (fColumn - 1)
        let spaceY = (pageHeight - fRow * cellSize.height) / (fRow - 1)
        
        spacing = CGSize(width: spaceX, height: spaceY)
        itemsPerPage = rowsPerPage * columnsPerPage
        
        // Determine the start pages of each section
        var total = 0
        let perPage = CGFloat(itemsPerPage)
        sectionStartPages.removeAll()
        
        for section in 0 ..< collectionView.numberOfSections() {
            sectionStartPages.append(total)
            total += Int(ceil(CGFloat(collectionView.numberOfItemsInSection(section)) / perPage))
        }
        
        // Record page count and content size
        _pageCount = total
        contentSize = CGSize(
            width: CGFloat(total) * collectionView.frame.width,
            height: collectionView.frame.height
        )
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let fromPage = max(Int(floor(rect.minX / collectionView.frame.width)), 0)
        let toPage = min(Int(floor(rect.maxX / collectionView.frame.width)), max(pageCount - 1, 0))
        let range = Array(fromPage ... toPage)
        
        let x = range.flatMap ({ (pageNumber) -> ([UICollectionViewLayoutAttributes]?) in
            guard let (section, firstPage) = sectionStartPages.enumerate().filter({ $0.1 <= pageNumber }).last else { return nil }
            let firstItem = (pageNumber - firstPage) * itemsPerPage
            let count = min(firstItem + itemsPerPage, collectionView.numberOfItemsInSection(section))
            return Array(firstItem ..< count).flatMap({
                let indexPath = NSIndexPath(forItem: $0, inSection: section)
                return layoutAttributesForItemAtIndexPath(indexPath)
            })
        })
        
        return Array(x.flatten())
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let pageNumber = pageForIndexPath(indexPath)
        guard let collectionView = collectionView,
            firstPage = sectionStartPages.filter({ $0 <= pageNumber }).last
            else { return nil }
        
        let pageX = CGFloat(pageNumber) * collectionView.frame.width
        let pageItemNumber = indexPath.item - (pageNumber - firstPage) * itemsPerPage
        let itemX = CGFloat(pageItemNumber % columnsPerPage) * (cellSize.width + spacing.width) + pageInsets.left
        let itemY = floor(CGFloat(pageItemNumber / columnsPerPage)) * (cellSize.height + spacing.height) + pageInsets.top
        
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = CGRect(origin: CGPoint(x: itemX + pageX, y: itemY), size: cellSize)
        return attr
    }
    
}