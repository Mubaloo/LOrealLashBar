//
//  BrushCarouselCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class BrushCarouselCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    var brush: Lash? {
        didSet {
            imageView.image = brush?.image
        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let attribs = layoutAttributes as? HighlightLayoutAttributes {
            let fromRange = FloatRange(start: 0, end: 1)
            let toRange = FloatRange(start: 0.3, end: 1)
            let a = Float(attribs.highlight).normalise(fromRange, toRange: toRange)
            alpha = CGFloat(a)
        }
    }
}
