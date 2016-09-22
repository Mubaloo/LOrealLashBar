//
//  TransitionAnimatableProtocol.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 30/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

protocol TransitionAnimatable {
    func prepare()
    func appear(duration: NSTimeInterval, delay: NSTimeInterval)
    func disappear(duration: NSTimeInterval, delay: NSTimeInterval)
}

enum TransitionAnimationDirection {
    case Appear, Disappear
}

enum TransitionAnimationMode {
    case Fade           // Simple alpha fade from 0 to current alpha
    case SlideLeft      // Slides in from or out to the left
    case SlideRight     // Slides in from or out to the right
    case SlideTop       // Slides in from or out to the top
    case SlideBottom    // Slides in from or out to the bottom
    case Scale          // Adjusts scale down from 120% - should accompany another mode
    case ScaleHorizontal
    case ScaleVertical
    case Native         // View must implement TransitionAnimatable
}

struct TransitionAnimationItem {
    let mode: TransitionAnimationMode
    let delay: NSTimeInterval           // Time from the beginning of the animation that this will occur
    let duration: NSTimeInterval?       // Nil duration means it lasts the full length of the transition
    let quantity: CGFloat?              // Optional - used in some modes for customisation. Nil = default.
    
    init(mode: TransitionAnimationMode, delay: NSTimeInterval = 0, duration: NSTimeInterval? = nil, quantity: CGFloat? = nil) {
        self.mode = mode
        self.delay = delay
        self.duration = duration
        self.quantity = quantity
    }
}

protocol TransitionAnimationDataSource {
    
    /** Return an array of all the views that will be animated. Return nil to use the default alpha blend animation. */
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]?
    
    /**
     Return the animation required for the specified view, or nil if no animation is required. Note that if you return
     nil here the view in question will remain on screen throughout the transition until obscured by the appearance of
     the destination view controller or revealed by the disappearance of the source view controller.
     */
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]?
    
    /**
     Return an array of views that should transition and cross-fade to other views in the target VC. Note that only the
     source VC is sent this message, so the direction of travel is always `Disappearing`.
     */
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]?
    
    /** 
     Return the view that is the equivalent of the passed view. Note that it is always the destination VC that receives
     this function call, so the direction of travel is always `Appearing`.
     */
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView?
    
}

extension TransitionAnimationDataSource {
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? { return nil }
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? { return nil }
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? { return nil }
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? { return nil }
}