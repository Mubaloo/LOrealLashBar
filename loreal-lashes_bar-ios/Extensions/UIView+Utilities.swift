//
//  UIView+Utilities.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 25/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

extension UIView {
    
    /** Returns a `UIImage` representing the receiver's current state. */
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContext(frame.size)
        let rect = CGRect(origin: CGPoint.zero, size: frame.size)
        drawHierarchy(in: rect, afterScreenUpdates: true)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     A convenience method that fades the receiver to 0% opacity, performs a block
     (typically to alter the appearance of the receiver) then fades it back in
     again. Useful for performing quick, simple view transitions.
     */
    func crossfadeUpdate(_ duration: TimeInterval, updates: @escaping ()->()) {
        let halfDuration = duration / 2
        UIView.animate(
            withDuration: halfDuration,
            animations: { self.alpha = 0 },
            completion: { [weak self] _ in
                updates()
                UIView.animate(
                    withDuration: halfDuration,
                    animations: { self?.alpha = 1 }
                )
            }
        )
    }
    
}
