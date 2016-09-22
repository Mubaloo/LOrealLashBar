//
//  AutoWidthLabel.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 22/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 A subclass of UILabel that automatically adjusts its width to fit a given number of rows
 of text. This is opposite to the usual behaviour which adjusts width first.
 */
class AutoWidthLabel: UILabel {

    override func intrinsicContentSize() -> CGSize {
        assert(numberOfLines > 0, "Need a definite number of lines to aim for!")
        guard let text = self.text else {
            return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
        }
        
        let singleLine = text.boundingRectWithSize(
            CGSize(width: Int.max, height: Int.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil
        )
        
        var approxWidth = singleLine.width / CGFloat(numberOfLines)
        var approx = CGRect.zero
        
        repeat {
            approxWidth += 10
            approx = text.boundingRectWithSize(
                CGSize(width: approxWidth, height: 1000),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil
            )
        } while approx.size.height > singleLine.height * 2
        
        return CGSize(
            width: ceil(approx.size.width),
            height: ceil(approx.size.height)
        )
    }
    
}
