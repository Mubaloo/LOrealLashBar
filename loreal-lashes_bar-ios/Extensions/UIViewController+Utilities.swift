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
    func reportError(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// By default, navigation controllers use their topmost view controller as animation data source
// if they conform to this protocol.

extension UINavigationController: TransitionAnimationDataSource {
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.transitionableViews(direction, otherVC: otherVC)
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.transitionAnimationItemsForView(view, direction: direction, otherVC: otherVC)
    }
    
    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.viewsWithEquivalents(otherVC)
    }
    
    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        guard let animatable = topViewController as? TransitionAnimationDataSource else { return nil }
        return animatable.equivalentViewForView(view, otherVC: otherVC)
    }
    
}
