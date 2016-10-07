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
    @IBInspectable var triangleColor: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        triangleColor.setFill()
        ctx?.beginPath()
        
        switch  direction {
        case 1 :
            ctx?.move(to: CGPoint(x: 0, y: 0))
            ctx?.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2))
            ctx?.addLine(to: CGPoint(x: 0, y: bounds.height))
        case 2 :
            ctx?.move(to: CGPoint(x: 0, y: bounds.height))
            ctx?.addLine(to: CGPoint(x: bounds.width / 2, y: 0))
            ctx?.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        case 3 :
            ctx?.move(to: CGPoint(x: bounds.width, y: 0))
            ctx?.addLine(to: CGPoint(x: 0, y: bounds.height / 2))
            ctx?.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        default :
            ctx?.move(to: CGPoint(x: 0, y: 0))
            ctx?.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
            ctx?.addLine(to: CGPoint(x: bounds.width, y: 0))
        }
        
        ctx?.closePath()
        ctx?.fillPath()
    }
    
}
