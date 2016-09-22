//
//  TintedBorderLayer.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TintedBorderLayer: CALayer {
    
    /**
     The size of gap to leave in the middle of the top line of the border. Note that this
     value is not used when `fromTopLeft` is true.
     */
    var titleWidth: CGFloat = 0
    
    /** The line width of the border. Defaults to 1. */
    var tintedBorderWidth: CGFloat = 1
    
    /** The amount of the border to draw, from 0 to 1. Used when animating drawing it. */
    var appearanceProgress: CGFloat = 1
    
    /** True if the animated line starts in the top left, false if it starts in the top centre. */
    var fromTopLeft: Bool = false
    
    private var gradient: CGGradientRef?
    
    override class func needsDisplayForKey(key: String) -> Bool {
        switch key {
        case "titleSize", "tintedBorderWidth", "appearanceProgress", "gradient", "fromTopLeft" : return true
        default: return super.needsDisplayForKey(key)
        }
    }
    
    override init() {
        super.init()
        self.setGradient(UIColor.blackColor(), to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    override init(layer: AnyObject) {
        if let borderLayer = layer as? TintedBorderLayer {
            self.titleWidth = borderLayer.titleWidth
            self.appearanceProgress = borderLayer.appearanceProgress
            self.gradient = borderLayer.gradient
            self.fromTopLeft = borderLayer.fromTopLeft
        }
        super.init(layer: layer)
        self.setGradient(UIColor.blackColor(), to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setGradient(UIColor.blackColor(), to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    private func setGradient(from: UIColor, to: UIColor) {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let colors: [CGFloat] = [
            r1, g1, b1, a1,
            r2, g2, b2, a2,
            r2, g2, b2, a2,
            r1, g1, b1, a1
        ]
        
        gradient = CGGradientCreateWithColorComponents(
            CGColorSpaceCreateDeviceRGB(),
            colors, nil, 4
        )
    }
    
    override func drawInContext(ctx: CGContext) {
        
        // 0 progress means it's completely invisible, so bail out
        if appearanceProgress == 0 { return }
        
        UIGraphicsPushContext(ctx)

        // Create the border path
        let border = CGPathCreateMutable()
        if appearanceProgress == 1 && titleWidth == 0 {
            CGPathAddRect(border, nil, bounds)
        } else {
            var progress = ((bounds.width + bounds.height) * 2 - titleWidth) * appearanceProgress
            
            // Draw from the top-left, or the top-centre leaving space for a title if required
            if fromTopLeft {
                CGPathMoveToPoint(border, nil, bounds.minX, bounds.minY)
                CGPathAddLineToPoint(border, nil, min(bounds.maxX, progress), bounds.minY)
                progress -= bounds.maxX
            } else {
                let startX = bounds.midX + titleWidth / 2
                CGPathMoveToPoint(border, nil, startX, bounds.minY)
                CGPathAddLineToPoint(border, nil, min(bounds.maxX, progress + startX), bounds.minY)
                progress -= bounds.maxX - startX
            }
            
            // Draw the right-hand side, if necessary
            if progress > 0 {
                CGPathAddLineToPoint(border, nil, bounds.maxX, min(bounds.maxY, progress))
                progress -= bounds.height
            }
            
            // Draw the bottom, if necessary
            if progress > 0 {
                CGPathAddLineToPoint(border, nil, bounds.maxX - min(bounds.maxX, progress), bounds.maxY)
                progress -= bounds.width
            }
            
            // Draw the left-hand side, if necessary
            if progress > 0 {
                CGPathAddLineToPoint(border, nil, bounds.minX, bounds.maxY - min(bounds.maxY, progress))
                progress -= bounds.height
            }
            
            // If we started from the centre, complete the square by drawing back up to it again.
            if progress > 0 && !fromTopLeft {
                CGPathAddLineToPoint(border, nil, progress, bounds.minY)
            }
        }
        
        
        // Use the outline to mask the context
        let stroked = CGPathCreateCopyByStrokingPath(border, nil, tintedBorderWidth * 2, .Butt, .Miter, 10)
        CGContextAddPath(ctx, stroked)
        CGContextClip(ctx)
        
        // Draw a linear gradient
        CGContextDrawLinearGradient(
            ctx, gradient,
            CGPoint(x: bounds.minX, y: 0),
            CGPoint(x: bounds.size.width, y: 0),
            []
        )
        
        UIGraphicsPopContext()
    }

}