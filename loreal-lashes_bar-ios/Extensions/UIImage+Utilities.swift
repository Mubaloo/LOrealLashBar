//
//  UIImage+Utilities.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 22/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     Returns a copy of the receiver, rotated 90 degrees. Used in the brush detail screen.
     An optional angle can be passed if other angles are required.
     */
    func rotate(angle: CGFloat = CGFloat(-M_PI_2)) -> UIImage {
        let newSize = CGSize(width: size.height, height: size.width)
        UIGraphicsBeginImageContext(newSize)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(ctx, 0, newSize.height)
        CGContextRotateCTM(ctx, angle)
        drawAtPoint(CGPoint.zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     Returns a copy of the receiver, adjusted to the passed scale. Note that this is a
     proportional transformation.
    */
    func scale(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(ctx, scale, scale)
        drawAtPoint(CGPoint.zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}