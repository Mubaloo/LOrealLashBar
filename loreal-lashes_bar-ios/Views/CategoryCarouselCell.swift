//
//  CategoryCarouselCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 19/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class CategoryCarouselCell: UICollectionViewCell {
    @IBOutlet var boldLabel: UILabel!
    @IBOutlet var regularLabel: UILabel!
    
    var text: String? {
        didSet {
            boldLabel.text = text
            regularLabel.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        boldLabel.textColor = UIColor.hotPink
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attribs = layoutAttributes as? HighlightLayoutAttributes {
            let value = CGFloat(FloatRange(start: 0, end: 1).constrain(Float(attribs.highlight)))
            boldLabel.alpha = value
            regularLabel.alpha = 1 - value
        }
    }
    
}
