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
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! HighlightLayoutAttributes
        copy.highlight = highlight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? HighlightLayoutAttributes {
            if (attributes.highlight == highlight) {
                return super.isEqual(object)
            }
        }
        return false
    }
    
}
