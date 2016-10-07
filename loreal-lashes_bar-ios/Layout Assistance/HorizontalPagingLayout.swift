//
//  HorizontalPagingLayout.swift
//  loreal-brush_bar-ios
//
//  Created by Igor Nakonetsnoi on 27/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 A layout that just allows horizontal paging without setting any of the other values.
 */

class HorizontalPagingLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let customOffset = targetOffsetFrom(proposedContentOffset)
        if customOffset != nil {
            return customOffset!
        }
        
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let customOffset = targetOffsetFrom(proposedContentOffset)
        if customOffset != nil {
            return customOffset!
        }
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    func targetOffsetFrom(_ proposedOffset: CGPoint) -> CGPoint? {
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedOffset.x + halfWidth;
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if let candAttrs = candidateAttributes {
                        
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                        
                    }
                    else { // == First time in the loop == //
                        
                        candidateAttributes = attributes;
                        continue;
                    }
                    
                    
                }
                
                return CGPoint(x : max(candidateAttributes!.center.x - halfWidth, 0) , y : proposedOffset.y);
                
            }
            
        }
        
        return nil
    }
}
