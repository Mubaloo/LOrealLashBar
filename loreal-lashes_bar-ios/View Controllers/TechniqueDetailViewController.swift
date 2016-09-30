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
    
    @IBOutlet var leftChevron: UIButton!
    @IBOutlet var rightChevron: UIButton!

    @IBOutlet var brushStack: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var didLoad: Bool = false
    var allTechniques = Technique.orderedTechniques()
    var selectedTag: Int!
    var technique: Technique? {
        didSet {
            if isViewLoaded() {
                updateRelatedProducts()
                updateTechniqueVideo()
                updateButtons()
                updateBasicData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewLayout = HorizontalPagingLayout()
        collectionViewLayout.itemSize = CGSizeMake(557, 200)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        collectionViewLayout.minimumInteritemSpacing = 60
        collectionViewLayout.minimumLineSpacing = 60
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        didLoad = false
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
//        guard let technique = technique else { return }

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
        
        leftChevron.enabled = (technique != allTechniques.first)
        rightChevron.enabled = (technique != allTechniques.last)
        
        if collectionView.visibleCells().count > 0, let currentCell = collectionView.visibleCells()[0] as? TechniqueDetailsCell {
            currentCell.addToPlaylistButton.userInteractionEnabled = !technique.inPlaylist
            if technique.inPlaylist {
                currentCell.addToPlaylistButton.setTitle("ADDED!", forState: .Normal)
                currentCell.addToPlaylistButton.enabled = false
            } else {
                currentCell.addToPlaylistButton.setTitle("ADD TO PLAYLIST", forState: .Normal)
                currentCell.addToPlaylistButton.enabled = true
            }
        }
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
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: newIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
    }
    
    @IBAction func scrollLeft(sender: UIButton) {
        shiftTechniques(-1)
    }
    
    @IBAction func scrollRight(sender: UIButton) {
        shiftTechniques(1)
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

// MARK: - CollectionViewDataSource
extension TechniqueDetailViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return min(allTechniques.count, 1)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTechniques.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TechniqueDetailsCell", forIndexPath: indexPath)
        if let techniqueCell = cell as? TechniqueDetailsCell {
            techniqueCell.technique = allTechniques[indexPath.row]
            if techniqueCell.addToPlaylistButton.allTargets().count == 0 {
                techniqueCell.addToPlaylistButton.addTarget(self, action: #selector(TechniqueDetailViewController.addToPlaylistTouched(_:)), forControlEvents: .TouchUpInside)
            }
            
            if techniqueCell.technique!.inPlaylist {
                techniqueCell.addToPlaylistButton.setTitle("ADDED!", forState: .Normal)
                techniqueCell.addToPlaylistButton.enabled = false
            } else {
                techniqueCell.addToPlaylistButton.setTitle("ADD TO PLAYLIST", forState: .Normal)
                techniqueCell.addToPlaylistButton.enabled = true
            }
        }
        return cell
    }
}

// MARK: - CollectionViewDelegate
extension TechniqueDetailViewController: UICollectionViewDelegate {
    internal func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let currentTechnique = technique, let newIndex = allTechniques.indexOf(currentTechnique) {
            // This positions the scroll view to the correct cell when the screen is opened
            if didLoad == false {
                didLoad = true
                let indexToScrollTo = NSIndexPath(forRow: newIndex, inSection: 0)
                collectionView.scrollToItemAtIndexPath(indexToScrollTo, atScrollPosition: .CenteredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - ScrollViewDelegate
extension TechniqueDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard collectionView.visibleCells().count > 0, let currentCell = collectionView.visibleCells()[0] as? TechniqueDetailsCell else {
            return
        }
        if collectionView.visibleCells().count == 1 && technique != currentCell.technique {
            self.technique = currentCell.technique
        }
    }
}

extension TechniqueDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [leftChevron, rightChevron]
        if collectionView.visibleCells().count > 0, let currentCell = collectionView.visibleCells()[0] as? TechniqueDetailsCell {
            views.append(currentCell.addToPlaylistButton)
            views.append(currentCell)
        }
        for stackView in brushStack.arrangedSubviews as! [UIStackView] {
            views.append(stackView.arrangedSubviews[0])
            views.append(stackView.arrangedSubviews[1])
        }
        
        if !(otherVC is TechniqueBrowserViewController) { views.append(videoContainer) }
        return views
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case is UIButton :
            return [TransitionAnimationItem(mode: .SlideRight, delay: 0.2, duration:  0.5)]
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
