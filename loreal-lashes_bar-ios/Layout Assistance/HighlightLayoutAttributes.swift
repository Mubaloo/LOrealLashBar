//
//  HighlightLayoutAttributes.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 19/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class HighlightLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var highlight: CGFloat = 1.0
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! HighlightLayoutAttributes
        copy.highlight = highlight
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? HighlightLayoutAttributes {
            if (attributes.highlight == highlight) {
                return super.isEqual(object)
            }
        }
        return false
    }
    
}