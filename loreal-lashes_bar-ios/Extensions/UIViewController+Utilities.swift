//
//  UIViewController+Utilities.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     Convenience method that displays a `UIAlertController` with the given title and message,
     accompanied by an Ok button that dismisses it. Typically used for warnings and errors.
     */
    func reportError(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

// By default, navigation controllers use their topmost view controller as animation data source
// if they conform to this protocol.

extension UINavigationController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.transitionableViews(direction, otherVC: otherVC)
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.transitionAnimationItemsForView(view, direction: direction, otherVC: otherVC)
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.viewsWithEquivalents(otherVC)
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.equivalentViewForView(view, otherVC: otherVC)
    }
    
}