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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    private func animationItemsForViewController(vc: UIViewController, direction: TransitionAnimationDirection, otherVC: UIViewController) -> TransitionCollection {
        var animations = TransitionCollection()
        
        if let animatable = vc as? TransitionAnimationDataSource,
            animatingViews = animatable.transitionableViews(direction, otherVC: otherVC) {
            for view in animatingViews {
                animations[view] = animatable.transitionAnimationItemsForView(view, direction: direction, otherVC: otherVC)
            }
        } else {
            let delay = (direction == .Appear) ? 0 : 0.5
            let fadeOut = TransitionAnimationItem(mode: .Fade, duration: 0.5, delay: delay)
            animations[vc.view] = [fadeOut]
        }
        
        return animations
    }
    
    private func equivalencyItems(fromVC: UIViewController, toVC: UIViewController, container: UIView) -> [EquivalencyData]? {
        guard let fromData = fromVC as? TransitionAnimationDataSource,
            toData = toVC as? TransitionAnimationDataSource,
            transitioning = fromData.viewsWithEquivalents(toVC)
            where transitioning.count > 0
            else { return nil }
        
        return transitioning.flatMap({
            guard let equivalent = toData.equivalentViewForView($0, otherVC: fromVC) else { return nil }
            
            // Convert the frames for the original and target view to a common ancestor
            let startFrame = container.convertRect($0.bounds, fromView: $0)
            let targetFrame = container.convertRect(equivalent.bounds, fromView: equivalent)
            
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
    
    private func logTransformIfNeeded(view: UIView, animation: TransitionAnimationItem) {
        switch animation.mode {
        case .SlideBottom, .SlideTop, .SlideLeft, .SlideRight,
             .Scale, .ScaleHorizontal, .ScaleVertical :
            priorTransform[view] = view.transform
        default: return
        }
    }
    
    // Gets each animatable view ready to animate. Also used to animate the current views out.
    private func prepareToAppear(view: UIView, animation: TransitionAnimationItem, container: UIView) {
        switch animation.mode {
        case .Fade :
            view.alpha = animation.quantity ?? 0
        case .Native :
            guard let animatable = view as? TransitionAnimatable else { fallthrough }
            animatable.prepare()
        case .SlideTop :
            let amount = animation.quantity ?? container.bounds.height
            view.transform = CGAffineTransformTranslate(view.transform, 0, -amount)
        case .SlideBottom :
            let amount = animation.quantity ?? container.bounds.height
            view.transform = CGAffineTransformTranslate(view.transform, 0, amount)
        case .SlideLeft :
            let amount = animation.quantity ?? container.bounds.width
            view.transform = CGAffineTransformTranslate(view.transform, -amount, 0)
        case .SlideRight :
            let amount = animation.quantity ?? container.bounds.width
            view.transform = CGAffineTransformTranslate(view.transform, amount, 0)
        case .Scale :
            let amount = animation.quantity ?? 2
            view.transform = CGAffineTransformScale(view.transform, amount, amount)
        case .ScaleHorizontal :
            let amount = animation.quantity ?? 2
            view.transform = CGAffineTransformScale(view.transform, amount, 1)
        case .ScaleVertical :
            let amount = animation.quantity ?? 2
            view.transform = CGAffineTransformScale(view.transform, 1, amount)
        }
    }
    
    private func performAppearanceAnimation(view: UIView, animation: TransitionAnimationItem, duration: NSTimeInterval, container: UIView) {

        // Native controls self-animate and shouldn't go into a navigation block
        if animation.mode == .Native {
            let delay = (animation.delay + 1) * duration
            let native = view as? TransitionAnimatable
            native?.appear(duration, delay: delay)
            return
        }
        
        let duration = animation.duration == nil ? 0.5 : animation.duration! / 2
        UIView.addKeyframeWithRelativeStartTime(
            animation.delay / 2 + 0.5, relativeDuration: duration,
            animations: {
                switch animation.mode {
                case .Fade : view.alpha = 1
                case .SlideTop, .SlideBottom, .SlideLeft, .SlideRight,
                .Scale, .ScaleHorizontal, .ScaleVertical :
                    if let transform = self.priorTransform[view] {
                        view.transform = transform
                        self.priorTransform[view] = nil
                    }
                case .Native : break // Natives are self-handling.
                }
        })
    }
    
    // Note that this calls `prepareToAppear()` above to set the actual states of each view.
    private func performDisappearanceAnimation(view: UIView, animation: TransitionAnimationItem, duration: NSTimeInterval, container: UIView) {
        let time = animation.duration != nil ? animation.duration! * duration : duration
        let delay = animation.duration == nil ? 0 : ((1 - animation.delay) * duration) - time
        
        // Native controls self-animate and shouldn't go into a navigation block
        if animation.mode == .Native {
            let native = view as? TransitionAnimatable
            native?.disappear(duration, delay: delay)
            return
        }
        
        let duration = animation.duration == nil ? 0.5 : animation.duration! / 2
        let relativeTime = max((1 - animation.delay) / 2 - duration, 0)
        UIView.addKeyframeWithRelativeStartTime(
            relativeTime, relativeDuration: duration,
            animations: {
                self.prepareToAppear(view, animation: animation, container: container)
        })
    }
    
    // Responsible for resetting a view to its proper values after it disappears. Important when dealing with
    // UINavigationController children.
    private func cleanUpAfterDisappearance(view: UIView, animation: TransitionAnimationItem) {
        switch animation.mode {
        case .Fade : view.alpha = 1
        case .SlideTop, .SlideBottom, .SlideLeft, .SlideRight,
             .Scale, .ScaleHorizontal, .ScaleVertical :
            if let transform = self.priorTransform[view] {
                view.transform = transform
                self.priorTransform[view] = nil
            }
        default : return
        }
    }
    
    private func performActionOnCollection(collection: TransitionCollection, action: (view: UIView, item: TransitionAnimationItem)->()) {
        for (view, items) in collection {
            for item in items {
                action(view: view, item: item)
            }
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Retrieve the various participants from the context
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!
        
        // Set up the destination view controller ready
        toVC.loadViewIfNeeded()
        toVC.view.frame = container.bounds
        toVC.view.layoutIfNeeded()
        toVC.view.alpha = 0
        container.addSubview(toVC.view)
        
        // Precalculate durations and fetch participant views
        let duration = transitionDuration(transitionContext) / 2
        let animateOut = animationItemsForViewController(fromVC, direction: .Disappear, otherVC: toVC)
        let animateIn = animationItemsForViewController(toVC, direction: .Appear, otherVC: fromVC)
        let equivalents = equivalencyItems(fromVC, toVC: toVC, container: container)
        
        // Record the transforms for views whose transforms will change
        performActionOnCollection(animateIn, action: { view, item in self.logTransformIfNeeded(view, animation: item) })
        performActionOnCollection(animateOut, action: { view, item in self.logTransformIfNeeded(view, animation: item) })
        
        UIView.animateKeyframesWithDuration(
            transitionDuration(transitionContext), delay: 0, options: [],
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
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0, animations: { toVC.view.alpha = 1 })
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
