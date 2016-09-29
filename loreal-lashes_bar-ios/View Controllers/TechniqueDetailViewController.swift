//
//  TechniqueDetailViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueDetailViewController: BaseViewController {
    
    @IBOutlet var videoContainer: AVPlayerView!
    
    @IBOutlet var techniqueDetailLabel: UILabel!
    @IBOutlet var brushNameLabel: UILabel!
    @IBOutlet var dataStack: UIStackView!
    
    @IBOutlet var leftChevron: UIButton!
    @IBOutlet var rightChevron: UIButton!
    @IBOutlet var addToPlaylistButton: UIButton!

    @IBOutlet var brushStack: UIStackView!
    
    var allTechniques = Technique.orderedTechniques()
    var selectedTag: Int!
    var technique: Technique? {
        didSet {
            if isViewLoaded() {
                updateRelatedProducts()
                updateTechniqueVideo()
                updateButtons()
            
                dataStack.crossfadeUpdate(0.5, updates: {
                    self.updateBasicData()
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        videoContainer.shouldInterruptTimeout = true
        
        videoContainer.delegate = self
    
        updateBasicData()
        updateTechniqueVideo()
        updateRelatedProducts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        videoContainer.play()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let brushDetailVC = segue.destinationViewController as? LashDetailViewController,
            product = technique!.orderedAssociates()[selectedTag] as? Lash {
            brushDetailVC.lash = product
        }
    }
    
    @IBAction func unwindToTechniqueDetail(sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
    
    // MARK:- Update Methods
    
    private func updateTechniqueVideo() {
        guard let technique = technique else { return }
        videoContainer.loadPlaylistItem(technique)
    }
    
    private func updateBasicData() {
        guard let technique = technique else { return }
        
        brushNameLabel.text = technique.name
        techniqueDetailLabel.text = technique.detail
    }
    
    private func updateRelatedProducts() {
        for view in brushStack.arrangedSubviews {
            brushStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let technique = technique else { return }
        
        for (index, product) in technique.orderedAssociates().enumerate() {
            
            let newStack = UIStackView()
            newStack.axis = .Vertical
            newStack.distribution = .EqualSpacing
            newStack.spacing = 0
            
            let titleLabel = UILabel()
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.font = UIFont(name: "HelveticaNeueCond", size: 18)
            titleLabel.text = product.name
            titleLabel.textAlignment = .Center
            titleLabel.numberOfLines = 1
            titleLabel.tag = index
            
            newStack.addArrangedSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.addConstraint(NSLayoutConstraint(
                item: titleLabel, attribute: .Height, relatedBy: .Equal,
                toItem: nil, attribute: .Height, multiplier: 0, constant: 30
                ))
            
            let image = product.image
            let imageView = UIImageView(image: image)
            imageView.contentMode = .ScaleAspectFit
            imageView.setContentHuggingPriority(240, forAxis: .Vertical)
            imageView.setContentCompressionResistancePriority(740, forAxis: .Vertical)
            imageView.tag = index
            
            newStack.addArrangedSubview(imageView)
            
            if product is Lash {
                let attribs: [String: AnyObject] = [
                    NSFontAttributeName : UIFont(name: "HelveticaNeueCond", size: 20)!,
                    NSForegroundColorAttributeName : UIColor.hotPink,
                    NSKernAttributeName : NSNumber(int: 2)
                ]
                
                let title = NSAttributedString(string: "LASH DETAILS", attributes: attribs)
                
                let button = AnimatedBorderButton(type: .Custom)
                button.tag = index
                button.setAttributedTitle(title, forState: .Normal)
                button.addTarget(self, action: #selector(TechniqueDetailViewController.selectedLash(_:)), forControlEvents: .TouchUpInside)
                newStack.addArrangedSubview(button)
            }
            
            brushStack.addArrangedSubview(newStack)
        }
    }
    
    private func updateButtons() {
        guard let technique = technique where isViewLoaded() else { return }
        addToPlaylistButton.userInteractionEnabled = !technique.inPlaylist
        if technique.inPlaylist {
            addToPlaylistButton.setTitle("ADDED!", forState: .Normal)
            addToPlaylistButton.enabled = false
        } else {
            addToPlaylistButton.setTitle("ADD TO PLAYLIST", forState: .Normal)
            addToPlaylistButton.enabled = true
        }
        
        leftChevron.enabled = (technique != allTechniques.first)
        rightChevron.enabled = (technique != allTechniques.last)
    }
    
    internal func selectedLash(sender: AnyObject?) {
        if let button = sender as? UIButton {
            selectedTag = button.tag
            performSegueWithIdentifier("lashDetailFromTechniqueDetail", sender: self)
        }
    }

    // MARK:- User Interactions
    
    private func shiftTechniques(direction: Int) {
        guard let technique = technique,
            index = allTechniques.indexOf(technique)
            else { return }
        
        let newIndex = index + direction
        if newIndex < 0 || newIndex >= allTechniques.count { return }
        self.technique = allTechniques[newIndex]
    }
    
    @IBAction func scrollLeft(sender: UIButton) {
        shiftTechniques(-1)
    }
    
    @IBAction func scrollRight(sender: UIButton) {
        shiftTechniques(1)
    }
    
    @IBAction func swipedRight(sender: AnyObject) {
        shiftTechniques(1)
    }
    
    @IBAction func swipedLeft(sender: AnyObject) {
        shiftTechniques(-1)
    }
    
    
    @IBAction func addToPlaylistTouched(sender: UIButton) {
        guard let technique = technique where !technique.inPlaylist else { return }
        technique.inPlaylist = true
        CoreDataStack.shared.saveContext()
        updateButtons()
    }
    
}

extension TechniqueDetailViewController: AVPlayerViewDelegate {
    func playerDidFinishPlaying(player: AVPlayerView) {
        videoContainer.reset()
    }
}

extension TechniqueDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [dataStack, addToPlaylistButton]
        for stackView in brushStack.arrangedSubviews as! [UIStackView] {
            views.append(stackView.arrangedSubviews[0])
            views.append(stackView.arrangedSubviews[1])
        }
        
        if !(otherVC is TechniqueBrowserViewController) { views.append(videoContainer) }
        return views
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case dataStack :
            return [TransitionAnimationItem(mode: .SlideRight, duration: 0.5)]
        case addToPlaylistButton :
            return [TransitionAnimationItem(mode: .SlideRight, delay: 0.1, duration: 0.5)]
        case videoContainer :
            return [TransitionAnimationItem(mode: .Fade)]
        default : break
        }
        
        let count = brushStack.arrangedSubviews.count
        let delay = 0.25 / Double(count) * Double(count - view.tag - 1) + 0.5
        if view is UILabel {
            return [TransitionAnimationItem(mode: .SlideLeft, delay: delay, duration: 0.25)]
        } else if view is UIImageView {
            return [TransitionAnimationItem(mode: .SlideBottom, delay: delay, duration: 0.25, quantity: view.frame.height)]
        }
        
        return nil
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if otherVC is TechniqueBrowserViewController { return [videoContainer] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return videoContainer
    }
    
}
