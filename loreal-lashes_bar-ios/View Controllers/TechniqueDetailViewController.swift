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
    var selectedTag: Int!
    
    lazy var allTechniques: [Technique] = {
        var orderedTechniques = Technique.orderedTechniques()
        orderedTechniques.insert(orderedTechniques.last!, atIndex: 0)
        orderedTechniques.append(orderedTechniques[1])
        return orderedTechniques
    }()
    
    var technique: Technique? {
        didSet {
            if isViewLoaded() {
                updateRelatedProducts()
                updateTechniqueVideo()
                updateButtons()
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
    
    @IBAction func unwindToTechniqueDetail(sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
    
    // MARK:- Update Methods
    
    private func updateTechniqueVideo() {
        guard let technique = technique else { return }
        videoContainer.loadPlaylistItem(technique)
    }
    
    private func updateRelatedProducts() {
        for view in brushStack.arrangedSubviews {
            brushStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let technique = technique else { return }
        
        let steps = [technique.step1, technique.step2, technique.step3]
        
        for (index, step) in steps.enumerate() {
            let containerView = UIView()
            containerView.backgroundColor = UIColor.clearColor()
            
            let titleLabel = UILabel()
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.font = UIFont(name: "HelveticaNeueCond", size: 28)
            titleLabel.text = "0\(index + 1)"
            titleLabel.textAlignment = .Center
            titleLabel.numberOfLines = 1
            containerView.addSubview(titleLabel)
            
            let image = UIImage(named: "zigzag_icon")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .ScaleAspectFit
            containerView.addSubview(imageView)
            
            let subtitleLabel = UILabel()
            subtitleLabel.textColor = UIColor.whiteColor()
            subtitleLabel.font = UIFont(name: "HelveticaNeueCond", size: 15)
            subtitleLabel.text = step
            subtitleLabel.textAlignment = .Center
            subtitleLabel.numberOfLines = 0
            containerView.addSubview(subtitleLabel)
            
            let maxSize = subtitleLabel.sizeOfText(withMaxSize:CGSizeMake(150, CGFloat.max))
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["title": titleLabel,
                         "image": imageView,
                         "subtitle": subtitleLabel]
            
            var allConstraints = [NSLayoutConstraint]()
            
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[title(35)]-20-[image(11)]-20-[subtitle(\(ceil(maxSize.height)))]",
                options: [.AlignAllCenterX],
                metrics: nil,
                views: views)
            allConstraints += verticalConstraints
            
            let iconHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[image(8)]",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += iconHorizontalConstraints
            
            let titleHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-0-[title]-0-|",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += titleHorizontalConstraints
            
            let subtitleHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-0-[subtitle]-0-|",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += subtitleHorizontalConstraints
            
            NSLayoutConstraint.activateConstraints(allConstraints)
        
            brushStack.addArrangedSubview(containerView)
        }
    }
    
    private func updateButtons() {
        guard let technique = technique where isViewLoaded() else { return }
        
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

    // MARK:- User Interactions
    
    private func shiftTechniques(direction: Int) {
        if collectionView.scrollEnabled == false {
            return
        }
        collectionView.scrollEnabled = false
        guard let cellIndex = self.collectionView.indexPathForCell(self.collectionView.visibleCells().first!)
            else { return }
        
        let newIndex = cellIndex.row + direction
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // disable scrolling so that the user can only scroll one page at a time
        scrollView.scrollEnabled = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateContinuousScrollIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateContinuousScrollIfNeeded()
    }
    
    // MARK: - Scrolling delegate helpers
    func updateContinuousScrollIfNeeded() {
        guard let cellIndex = self.collectionView.indexPathForCell(self.collectionView.visibleCells().first!)
            else { return }
        if cellIndex.row == 0 {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: allTechniques.count - 2, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
        }else if cellIndex.row == allTechniques.count - 1 {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
        }
        collectionView.scrollEnabled = true
    }
}

extension TechniqueDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [leftChevron, rightChevron]
        if collectionView.visibleCells().count > 0, let currentCell = collectionView.visibleCells()[0] as? TechniqueDetailsCell {
            views.append(currentCell.addToPlaylistButton)
            views.append(currentCell)
        }
        for view in brushStack.arrangedSubviews {
            views.append(view)
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
        return [TransitionAnimationItem(mode: .SlideLeft, delay: delay, duration: 0.25)]
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if otherVC is TechniqueBrowserViewController { return [videoContainer] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return videoContainer
    }
    
}
