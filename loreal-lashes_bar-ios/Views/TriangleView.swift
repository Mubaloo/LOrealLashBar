//
//  TriangleView.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 26/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/** A super-simple custom view designed to draw a triangle fitting its bounds. */
@IBDesignable class TriangleView: UIView {
    
    @IBInspectable var direction: Int = 0 { didSet { setNeedsDisplay() } }
    @IBInspectable var triangleColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        triangleColor.setFill()
        CGContextBeginPath(ctx)
        
        switch  direction {
        case 1 :
            CGContextMoveToPoint(ctx, 0, 0)
            CGContextAddLineToPoint(ctx, bounds.width, bounds.height / 2)
            CGContextAddLineToPoint(ctx, 0, bounds.height)
        case 2 :
            CGContextMoveToPoint(ctx, 0, bounds.height)
            CGContextAddLineToPoint(ctx, bounds.width / 2, 0)
            CGContextAddLineToPoint(ctx, bounds.width, bounds.height)
        case 3 :
            CGContextMoveToPoint(ctx, bounds.width, 0)
            CGContextAddLineToPoint(ctx, 0, bounds.height / 2)
            CGContextAddLineToPoint(ctx, bounds.width, bounds.height)
        default :
            CGContextMoveToPoint(ctx, 0, 0)
            CGContextAddLineToPoint(ctx, bounds.width / 2, bounds.height)
            CGContextAddLineToPoint(ctx, bounds.width, 0)
        }
        
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
    }
    
}