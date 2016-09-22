//
//  AttractModeViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 16/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class AttractModeViewController: BaseViewController {

    @IBOutlet var brushButton: UIButton!
    @IBOutlet var techniqueButton: UIButton!
    
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet var browseByLabels: [UILabel]!
    @IBOutlet var brushImages: [UIImageView]!
    @IBOutlet var techniqueImages: [UIImageView]!
    
    @IBOutlet var divider: UIView!
    
    private var flipOrder = [0, 3, 4, 1, 2, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Color scheme
        view.backgroundColor = UIColor.lightBG
        for label in browseByLabels { label.textColor = UIColor.hotPink }
        for button in [brushButton, techniqueButton] {
            button.setTitleColor(UIColor.hotPink, forState: .Normal)
        }
        
        // Rotate, scale and position individual brushes
        for (index, image) in brushImages.enumerate() {
            let rhs = (index % 2 == 1)
            let aln = (index / 2 % 2 == 1)
            let angle = rhs ? -M_PI_2 : M_PI_2
            let indent: CGFloat = aln ? 120 : 50
            
            var transform = CGAffineTransformMakeRotation(CGFloat(angle))
            transform = CGAffineTransformTranslate(transform, 0, indent)
            if rhs { transform = CGAffineTransformScale(transform, -1, 1) }
            image.transform = CGAffineTransformScale(transform, 0.5, 0.5)
        }
        
        // TODO: this will eventually be replaced with a nightly-updated web service
        let service = TextFileService()
        service.populateDatabase({ error in
            if let error = error {
                self.reportError("Error", message: "Could not populate database: \(error)")
            } else {
                CoreDataStack.shared.managedObjectContext.catalogueAllManagedObjects()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.performSelector(#selector(AttractModeViewController.animateRandomBrush), withObject: nil, afterDelay: Double(arc4random_uniform(4)) + 2.5) // used 2.5 here to ensure animations never happen at the exact the same time.
        self.performSelector(#selector(AttractModeViewController.flipRandomPhoto), withObject: nil, afterDelay: Double(arc4random_uniform(4)) + 2)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tbvc = segue.destinationViewController as? TitleBarViewController {
            guard let button = sender as? UIButton else { return }
            switch button {
            case brushButton : tbvc.setBrowserType(.Lashes)
            case techniqueButton : tbvc.setBrowserType(.Technique)
            default : break
            }
        }
    }
    
    @IBAction func browserChosen(sender: UIButton) {
        performSegueWithIdentifier("ExitAttractMode", sender: sender)
    }
    
    @IBAction func testFlip(sender: AnyObject) {
        flipRandomPhoto()
    }
    
    // MARK:- Custom Animation
    
    private func randomNumber(range: Range<Int> = 1...6) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func animateRandomBrush() {
        let imageIndex = Int(arc4random_uniform(UInt32(brushImages.count)))
        let image = brushImages[imageIndex]
        let adjust: CGFloat = (imageIndex % 2 == 0) ? -100 : 100
        let newCenter = CGPoint(x: image.center.x + adjust, y: image.center.y)
        let animation = CABasicAnimation()
        animation.autoreverses = true
        animation.toValue = NSValue(CGPoint: newCenter)
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        image.layer.addAnimation(animation, forKey: "position")

        self.performSelector(#selector(AttractModeViewController.animateRandomBrush), withObject: nil, afterDelay: Double(arc4random_uniform(4)) + 2)
    }
    
    func flipRandomPhoto() {
        
        // Cycle through the images in a balanced order
        let index = flipOrder[0]
        flipOrder.append(index)
        flipOrder.removeAtIndex(0)
        let imageView = techniqueImages[index]
        
        // Don't replace an image with the same image
        var newTag = imageView.tag
        let allTags = techniqueImages.map({ $0.tag })
        while allTags.contains(newTag) { newTag = randomNumber(1...12) }
        let imageName = String(format: "%02d-Technique", newTag)
        guard let image = UIImage(named: imageName) else { return }
        
        // Flip the image over, replacing it halfway through
        imageView.tag = newTag
        UIView.animateWithDuration(
            0.25,
            animations: {
                imageView.transform = CGAffineTransformMakeScale(0.0001, 1)
            },
            completion: { _ in
                imageView.image = image
                UIView.animateWithDuration(
                    0.25,
                    animations: { imageView.transform = CGAffineTransformIdentity })
            }
        )
        self.performSelector(#selector(AttractModeViewController.flipRandomPhoto), withObject: nil, afterDelay: Double(arc4random_uniform(4)) + 2)
    }
    
}

extension AttractModeViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var allViews = brushImages as [UIView]
        allViews.appendContentsOf(techniqueImages as [UIView])
        allViews.appendContentsOf(browseByLabels as [UIView])
        allViews.appendContentsOf(titleLabels as [UIView])
        allViews.appendContentsOf([brushButton, techniqueButton, divider])
        return allViews
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if let imageView = view as? UIImageView {
            var mode: TransitionAnimationMode
            if let index = brushImages.indexOf(imageView) ?? techniqueImages.indexOf(imageView) {
                if brushImages.contains(imageView) { mode = .SlideBottom }
                else if index % 2 == 0 { mode = .SlideLeft }
                else { mode = .SlideRight }
                let delay = NSTimeInterval(index / 2) * 0.1
                return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
            }
        }
        
        if view is UILabel {
            return [TransitionAnimationItem(mode: .Fade, delay: 0, duration: 0.5)]
        }
        
        if view is TransitionAnimatable {
            return [TransitionAnimationItem(mode: .Native, delay: 0.5, duration: 0.5)]
        }
        
        if view == divider {
            return [TransitionAnimationItem(mode: .ScaleHorizontal, delay: 0, duration: 0.5, quantity: 0)]
        }
        
        return nil
    }
    
}
