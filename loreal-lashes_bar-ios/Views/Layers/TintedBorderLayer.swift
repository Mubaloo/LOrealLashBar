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
    
    fileprivate var gradient: CGGradient?
    
    override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case "titleSize", "tintedBorderWidth", "appearanceProgress", "gradient", "fromTopLeft" : return true
        default: return super.needsDisplay(forKey: key)
        }
    }
    
    override init() {
        super.init()
        self.setGradient(UIColor.black, to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    override init(layer: Any) {
        if let borderLayer = layer as? TintedBorderLayer {
            self.titleWidth = borderLayer.titleWidth
            self.appearanceProgress = borderLayer.appearanceProgress
            self.gradient = borderLayer.gradient
            self.fromTopLeft = borderLayer.fromTopLeft
        }
        super.init(layer: layer)
        self.setGradient(UIColor.black, to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setGradient(UIColor.black, to: UIColor.hotPink)
        self.setNeedsDisplay()
    }
    
    fileprivate func setGradient(_ from: UIColor, to: UIColor) {
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
        
        gradient = CGGradient(
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            colorComponents: colors, locations: nil, count: 4
        )
    }
    
    override func draw(in ctx: CGContext) {
        
        // 0 progress means it's completely invisible, so bail out
        if appearanceProgress == 0 { return }
        
        UIGraphicsPushContext(ctx)

        // Create the border path
        let border = CGMutablePath()
        if appearanceProgress == 1 && titleWidth == 0 {
            border.addRect(bounds)
        } else {
            var progress = ((bounds.width + bounds.height) * 2 - titleWidth) * appearanceProgress
            
            // Draw from the top-left, or the top-centre leaving space for a title if required
            if fromTopLeft {
                border.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
                border.addLine(to: CGPoint(x: min(bounds.maxX, progress), y: bounds.minY))
                progress -= bounds.maxX
            } else {
                let startX = bounds.midX + titleWidth / 2
                border.move(to: CGPoint(x: startX, y: bounds.minY))
                border.addLine(to: CGPoint(x: min(bounds.maxX, progress + startX), y: bounds.minY))
                progress -= bounds.maxX - startX
            }
            
            // Draw the right-hand side, if necessary
            if progress > 0 {
                border.addLine(to: CGPoint(x: bounds.maxX, y: min(bounds.maxY, progress)))
                progress -= bounds.height
            }
            
            // Draw the bottom, if necessary
            if progress > 0 {
                border.addLine(to: CGPoint(x: bounds.maxX - min(bounds.maxX, progress), y: bounds.maxY))
                progress -= bounds.width
            }
            
            // Draw the left-hand side, if necessary
            if progress > 0 {
                border.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY - min(bounds.maxY, progress)))
                progress -= bounds.height
            }
            
            // If we started from the centre, complete the square by drawing back up to it again.
            if progress > 0 && !fromTopLeft {
                border.addLine(to: CGPoint(x: progress, y: bounds.minY))
            }
        }
        
        
        // Use the outline to mask the context
        let stroked = CGPath(__byStroking: border, transform: nil, lineWidth: tintedBorderWidth * 2, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
        ctx.addPath(stroked!)
        ctx.clip()
        
        // Draw a linear gradient
        ctx.drawLinearGradient(gradient!,
            start: CGPoint(x: bounds.minX, y: 0),
            end: CGPoint(x: bounds.size.width, y: 0),
            options: []
        )
        
        UIGraphicsPopContext()
    }

}
