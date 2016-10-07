//
//  SelfDrivenTransition.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 30/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

typealias TransitionCollection = [UIView : [TransitionAnimationItem]]

private struct EquivalencyData {
    let fromView: UIView
    let toView: UIView
    let fromImposter: UIImageView
    let toImposter: UIImageView
    let targetFrame: CGRect
}

class SelfDrivenTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var priorTransform = [UIView : CGAffineTransform]()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    fileprivate func animationItemsForViewController(_ vc: UIViewController, direction: TransitionAnimationDirection, otherVC: UIViewController) -> TransitionCollection {
        var animations = TransitionCollection()
        
        if let animatable = vc as? TransitionAnimationDataSource,
            let animatingViews = animatable.transitionableViews(direction, otherVC: otherVC) {
            for view in animatingViews {
                animations[view] = animatable.transitionAnimationItemsForView(view, direction: direction, otherVC: otherVC)
            }
        } else {
            let delay = (direction == .appear) ? 0 : 0.5
            let fadeOut = TransitionAnimationItem(mode: .fade, delay: delay, duration: 0.5)
            animations[vc.view] = [fadeOut]
        }
        
        return animations
    }
    
    fileprivate func equivalencyItems(_ fromVC: UIViewController, toVC: UIViewController, container: UIView) -> [EquivalencyData]? {
        guard let fromData = fromVC as? TransitionAnimationDataSource,
            let toData = toVC as? TransitionAnimationDataSource,
            let transitioning = fromData.viewsWithEquivalents(toVC)
            , transitioning.count > 0
            else { return nil }
        
        return transitioning.flatMap({
            guard let equivalent = toData.equivalentViewForView($0, otherVC: fromVC) else { return nil }
            
            // Convert the frames for the original and target view to a common ancestor
            let startFrame = container.convert($0.bounds, from: $0)
            let targetFrame = container.convert(equivalent.bounds, from: equivalent)
            
            // Prepare two image views to replace the originals during transitions
            let imposterA = UIImageView(image: $0.snapshot())
            let imposterB = UIImageView(image: equivalent.snapshot())
            imposterA.frame = startFrame
            imposterB.frame = startFrame
            imposterB.alpha = 0
            
            // Set up the view hierarchy ready to transition
            container.addSubview(imposterA)
            container.addSubview(imposterB)
            equivalent.alpha = 0
            $0.alpha = 0
            
            // Compile and return the actual equivalency data
            return EquivalencyData(
                fromView: $0,
                toView: equivalent,
                fromImposter: imposterA,
                toImposter: imposterB,
                targetFrame: targetFrame
            )
        })
    }
    
    fileprivate func logTransformIfNeeded(_ view: UIView, animation: TransitionAnimationItem) {
        switch animation.mode {
        case .slideBottom, .slideTop, .slideLeft, .slideRight,
             .scale, .scaleHorizontal, .scaleVertical :
            priorTransform[view] = view.transform
        default: return
        }
    }
    
    // Gets each animatable view ready to animate. Also used to animate the current views out.
    fileprivate func prepareToAppear(_ view: UIView, animation: TransitionAnimationItem, container: UIView) {
        switch animation.mode {
        case .fade :
            view.alpha = animation.quantity ?? 0
        case .native :
            guard let animatable = view as? TransitionAnimatable else { fallthrough }
            animatable.prepare()
        case .slideTop :
            let amount = animation.quantity ?? container.bounds.height
            view.transform = view.transform.translatedBy(x: 0, y: -amount)
        case .slideBottom :
            let amount = animation.quantity ?? container.bounds.height
            view.transform = view.transform.translatedBy(x: 0, y: amount)
        case .slideLeft :
            let amount = animation.quantity ?? container.bounds.width
            view.transform = view.transform.translatedBy(x: -amount, y: 0)
        case .slideRight :
            let amount = animation.quantity ?? container.bounds.width
            view.transform = view.transform.translatedBy(x: amount, y: 0)
        case .scale :
            let amount = animation.quantity ?? 2
            view.transform = view.transform.scaledBy(x: amount, y: amount)
        case .scaleHorizontal :
            let amount = animation.quantity ?? 2
            view.transform = view.transform.scaledBy(x: amount, y: 1)
        case .scaleVertical :
            let amount = animation.quantity ?? 2
            view.transform = view.transform.scaledBy(x: 1, y: amount)
        }
    }
    
    fileprivate func performAppearanceAnimation(_ view: UIView, animation: TransitionAnimationItem, duration: TimeInterval, container: UIView) {

        // Native controls self-animate and shouldn't go into a navigation block
        if animation.mode == .native {
            let delay = (animation.delay + 1) * duration
            let native = view as? TransitionAnimatable
            native?.appear(duration, delay: delay)
            return
        }
        
        let duration = animation.duration == nil ? 0.5 : animation.duration! / 2
        UIView.addKeyframe(
            withRelativeStartTime: animation.delay / 2 + 0.5, relativeDuration: duration,
            animations: {
                switch animation.mode {
                case .fade : view.alpha = 1
                case .slideTop, .slideBottom, .slideLeft, .slideRight,
                .scale, .scaleHorizontal, .scaleVertical :
                    if let transform = self.priorTransform[view] {
                        view.transform = transform
                        self.priorTransform[view] = nil
                    }
                case .native : break // Natives are self-handling.
                }
        })
    }
    
    // Note that this calls `prepareToAppear()` above to set the actual states of each view.
    fileprivate func performDisappearanceAnimation(_ view: UIView, animation: TransitionAnimationItem, duration: TimeInterval, container: UIView) {
        let time = animation.duration != nil ? animation.duration! * duration : duration
        let delay = animation.duration == nil ? 0 : ((1 - animation.delay) * duration) - time
        
        // Native controls self-animate and shouldn't go into a navigation block
        if animation.mode == .native {
            let native = view as? TransitionAnimatable
            native?.disappear(duration, delay: delay)
            return
        }
        
        let duration = animation.duration == nil ? 0.5 : animation.duration! / 2
        let relativeTime = max((1 - animation.delay) / 2 - duration, 0)
        UIView.addKeyframe(
            withRelativeStartTime: relativeTime, relativeDuration: duration,
            animations: {
                self.prepareToAppear(view, animation: animation, container: container)
        })
    }
    
    // Responsible for resetting a view to its proper values after it disappears. Important when dealing with
    // UINavigationController children.
    fileprivate func cleanUpAfterDisappearance(_ view: UIView, animation: TransitionAnimationItem) {
        switch animation.mode {
        case .fade : view.alpha = 1
        case .slideTop, .slideBottom, .slideLeft, .slideRight,
             .scale, .scaleHorizontal, .scaleVertical :
            if let transform = self.priorTransform[view] {
                view.transform = transform
                self.priorTransform[view] = nil
            }
        default : return
        }
    }
    
    fileprivate func performActionOnCollection(_ collection: TransitionCollection, action: (_ view: UIView, _ item: TransitionAnimationItem)->()) {
        for (view, items) in collection {
            for item in items {
                action(view, item)
            }
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Retrieve the various participants from the context
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let container = transitionContext.containerView
        
        // Set up the destination view controller ready
        toVC.loadViewIfNeeded()
        toVC.view.frame = container.bounds
        toVC.view.layoutIfNeeded()
        toVC.view.alpha = 0
        container.addSubview(toVC.view)
        
        // Precalculate durations and fetch participant views
        let duration = transitionDuration(using: transitionContext) / 2
        let animateOut = animationItemsForViewController(fromVC, direction: .disappear, otherVC: toVC)
        let animateIn = animationItemsForViewController(toVC, direction: .appear, otherVC: fromVC)
        let equivalents = equivalencyItems(fromVC, toVC: toVC, container: container)
        
        // Record the transforms for views whose transforms will change
        performActionOnCollection(animateIn, action: { view, item in self.logTransformIfNeeded(view, animation: item) })
        performActionOnCollection(animateOut, action: { view, item in self.logTransformIfNeeded(view, animation: item) })
        
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext), delay: 0, options: [],
            animations: {
                
                // Deal with equivalent views first
                if let equivalents = equivalents {
                    for data in equivalents {
                        data.fromImposter.alpha = 0
                        data.toImposter.alpha = 1
                        data.fromImposter.frame = data.targetFrame
                        data.toImposter.frame = data.targetFrame
                    }
                }
                
                // Now deal with views that are disappearing or appearing.
                self.performActionOnCollection(animateIn, action: { view, item in self.prepareToAppear(view, animation: item, container: container) })
                self.performActionOnCollection(animateOut, action: { view, item in self.performDisappearanceAnimation(view, animation: item, duration: duration, container: container) })
                self.performActionOnCollection(animateIn, action: { view, item in self.performAppearanceAnimation(view, animation: item, duration: duration, container: container) })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0, animations: { toVC.view.alpha = 1 })
            },
            completion: { finished in
                
                // Tidy up equivalents that are no longer required
                if let equivalents = equivalents {
                    for data in equivalents {
                        data.fromView.alpha = 1
                        data.toView.alpha = 1
                        data.fromImposter.removeFromSuperview()
                        data.toImposter.removeFromSuperview()
                    }
                }
                
                // Clean up other views and complete the transition.
                self.performActionOnCollection(animateOut, action: { view, item in self.cleanUpAfterDisappearance(view, animation: item) })
                transitionContext.completeTransition(true)
        })
    }
    
}
