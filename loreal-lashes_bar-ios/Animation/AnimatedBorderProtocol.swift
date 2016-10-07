//
//  AnimatedBorderProtocol.swift
//  loreal-lash_bar-ios
//
//  Created by Jonathan Gwilliams on 30/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/** 
 Any view can have an animated border, simply by adopting this protocol. You don't even have to
 implement the `fadeInSubviews()` function as this is handled by the extension. Just ensure that
 a border layer is created and added in a suitable superlayer.
 */
protocol AnimatedBorderProtocol: TransitionAnimatable {
    var borderLayer: TintedBorderLayer { get }
    func fadeInSubviews() -> [UIView]
}

extension AnimatedBorderProtocol {
    
    fileprivate func animateAppearance(_ from: Float, to: Float, duration: TimeInterval, delay: TimeInterval) {
        
        let fadingViews = fadeInSubviews()
        let halfDuration = duration / 2
        let hasFade = fadingViews.count > 0
        let fadingOut = (to < from)
        let borderDelay = (fadingOut && hasFade) ? halfDuration : 0
        let borderDuration = hasFade ? halfDuration : duration
        
        let borderAnim = CABasicAnimation()
        borderAnim.fromValue = NSNumber(value: from as Float)
        borderAnim.toValue = NSNumber(value: to as Float)
        borderAnim.duration = borderDuration
        borderAnim.beginTime = CACurrentMediaTime() + borderDelay + delay
        
        borderLayer.removeAnimation(forKey: "appearanceProgress")
        
        let dispatchTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.borderLayer.add(borderAnim, forKey: "appearanceProgress")
            self.borderLayer.appearanceProgress = CGFloat(to)
            if hasFade == false { return }
            
            let fadeDelay = fadingOut ? 0 : halfDuration
            for view in self.fadeInSubviews() {
                UIView.animate(withDuration: halfDuration, delay: fadeDelay, options: [],
                    animations: { view.alpha = CGFloat(to) }, completion: nil)
            }
        })
    }
    
    func fadeInSubviews() -> [UIView] { return [] }
    
    func prepare() {
        UIView.performWithoutAnimation({
            for view in self.fadeInSubviews() { view.alpha = 0 }
            self.borderLayer.appearanceProgress = 0
            self.borderLayer.setNeedsDisplay()
        })
    }
    
    func appear(_ duration: TimeInterval, delay: TimeInterval) {
        animateAppearance(0, to: 1, duration: 1, delay: delay) // overwritten duration as a quick fix. Should add a custom duration variable in the future.
    }
    
    func disappear(_ duration: TimeInterval, delay: TimeInterval) {
        animateAppearance(1, to: 0, duration: 1, delay: delay)
    }
    
}
