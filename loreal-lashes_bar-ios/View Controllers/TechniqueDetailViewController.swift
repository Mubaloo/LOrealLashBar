//
//  TechniqueDetailViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueDetailViewController: BaseViewController {
    
    @IBOutlet var videoContainer: UIView!
    
    @IBOutlet var leftChevron: UIButton!
    @IBOutlet var rightChevron: UIButton!

    @IBOutlet var brushStack: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let videoPlayer = AVSharedPlayerView.sharedInstance
    
    var didLoad: Bool = false
    var selectedTag: Int!
    
    lazy var allTechniques: [Technique] = {
        var orderedTechniques = Technique.orderedTechniques()
        orderedTechniques.insert(orderedTechniques.last!, at: 0)
        orderedTechniques.append(orderedTechniques[1])
        return orderedTechniques
    }()
    
    var technique: Technique? {
        didSet {
            if isViewLoaded {
                updateRelatedProducts()
                updateTechniqueVideo()
                updateButtons()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewLayout = HorizontalPagingLayout()
        collectionViewLayout.itemSize = CGSize(width: 557, height: 200)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        collectionViewLayout.minimumInteritemSpacing = 60
        collectionViewLayout.minimumLineSpacing = 60
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        view.backgroundColor = UIColor.lightBG
        
        setupPlayer()
    
        updateTechniqueVideo()
        updateRelatedProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPlayer.playerView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didLoad = false
    }
    
    deinit {
        self.videoPlayer.cleanUp()
    }
    
    func stopTimeout() {
        let app = UIApplication.shared as! TimeOutApplication
        app.pauseTimeout()
    }

    @IBAction func unwindToTechniqueDetail(_ sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
    
    // MARK:- Player setup
    private func setupPlayer() {
        self.videoContainer.insertSubview(videoPlayer, at: 0)
        
        let topConstraint = NSLayoutConstraint(item: videoPlayer, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: videoContainer, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: videoPlayer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: videoContainer, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: videoPlayer, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: videoContainer, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: videoPlayer, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: videoContainer, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        
        
        videoPlayer.playerView.shouldInterruptTimeout = true
        
        videoPlayer.playerView.delegate = self
        
    }
    
    // MARK:- Update Methods
    
    fileprivate func updateTechniqueVideo() {
        guard let technique = technique else { return }
        videoPlayer.playerView.imposter!.image = technique.thumbnail
        videoPlayer.playerView.loadPlaylistItem(technique)
    }
    
    fileprivate func updateRelatedProducts() {
        for view in brushStack.arrangedSubviews {
            brushStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let technique = technique else { return }
        
        let steps = [technique.step1, technique.step2, technique.step3]
        
        for (index, step) in steps.enumerated() {
            let containerView = UIView()
            containerView.backgroundColor = UIColor.clear
            
            let titleLabel = UILabel()
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "HelveticaNeueCond", size: 28)
            titleLabel.text = "0\(index + 1)"
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 1
            containerView.addSubview(titleLabel)
            
            let image = UIImage(named: "zigzag_icon")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            containerView.addSubview(imageView)
            
            let subtitleLabel = UILabel()
            subtitleLabel.textColor = UIColor.white
            subtitleLabel.font = UIFont(name: "HelveticaNeueCond", size: 15)
            subtitleLabel.text = step
            subtitleLabel.textAlignment = .center
            subtitleLabel.numberOfLines = 0
            containerView.addSubview(subtitleLabel)
            
            let maxSize = subtitleLabel.sizeOfText(withMaxSize:CGSize(width: 150, height: CGFloat.greatestFiniteMagnitude))
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["title": titleLabel,
                         "image": imageView,
                         "subtitle": subtitleLabel]
            
            var allConstraints = [NSLayoutConstraint]()
            
            let verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[title(35)]-20-[image(11)]-20-[subtitle(\(ceil(maxSize.height)))]",
                options: [.alignAllCenterX],
                metrics: nil,
                views: views)
            allConstraints += verticalConstraints
            
            let iconHorizontalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:[image(8)]",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += iconHorizontalConstraints
            
            let titleHorizontalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[title]-0-|",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += titleHorizontalConstraints
            
            let subtitleHorizontalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[subtitle]-0-|",
                options: [],
                metrics: nil,
                views: views)
            allConstraints += subtitleHorizontalConstraints
            
            NSLayoutConstraint.activate(allConstraints)
        
            brushStack.addArrangedSubview(containerView)
        }
    }
    
    fileprivate func updateButtons() {
        guard let technique = technique , isViewLoaded else { return }
        
        if collectionView.visibleCells.count > 0, let currentCell = collectionView.visibleCells[0] as? TechniqueDetailsCell {
            if technique.inPlaylist {
                currentCell.addToPlaylistButton.setTitle("ADDED!", for: UIControlState())
                currentCell.addToPlaylistButton.isEnabled = false
            } else {
                currentCell.addToPlaylistButton.setTitle("ADD TO PLAYLIST", for: UIControlState())
                currentCell.addToPlaylistButton.isEnabled = true
            }
        }
    }

    // MARK:- User Interactions
    
    fileprivate func shiftTechniques(_ direction: Int) {
        if collectionView.isScrollEnabled == false {
            return
        }
        collectionView.isScrollEnabled = false
        guard let cellIndex = self.collectionView.indexPath(for: self.collectionView.visibleCells.first!)
            else { return }
        
        let newIndex = (cellIndex as NSIndexPath).row + direction
        self.collectionView.scrollToItem(at: IndexPath(item: newIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func scrollLeft(_ sender: UIButton) {
        shiftTechniques(-1)
    }
    
    @IBAction func scrollRight(_ sender: UIButton) {
        shiftTechniques(1)
    }
    
    @IBAction func addToPlaylistTouched(_ sender: UIButton) {
        guard let technique = technique , !technique.inPlaylist else { return }
        technique.inPlaylist = true
        CoreDataStack.shared.saveContext()
        updateButtons()
    }
    
}

extension TechniqueDetailViewController: AVPlayerViewDelegate {
    func playerDidFinishPlaying(_ player: AVPlayerView) {
        videoPlayer.playerView.reset()
    }
}

// MARK: - CollectionViewDataSource
extension TechniqueDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return min(allTechniques.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTechniques.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TechniqueDetailsCell", for: indexPath)
        if let techniqueCell = cell as? TechniqueDetailsCell {
            techniqueCell.technique = allTechniques[(indexPath as NSIndexPath).row]
            if techniqueCell.addToPlaylistButton.allTargets.count == 0 {
                techniqueCell.addToPlaylistButton.addTarget(self, action: #selector(TechniqueDetailViewController.addToPlaylistTouched(_:)), for: .touchUpInside)
            }
            
            if techniqueCell.technique!.inPlaylist {
                techniqueCell.addToPlaylistButton.setTitle("ADDED!", for: UIControlState())
                techniqueCell.addToPlaylistButton.isEnabled = false
            } else {
                techniqueCell.addToPlaylistButton.setTitle("ADD TO PLAYLIST", for: UIControlState())
                techniqueCell.addToPlaylistButton.isEnabled = true
            }
        }
        return cell
    }
}

// MARK: - CollectionViewDelegate
extension TechniqueDetailViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let currentTechnique = technique, let newIndex = allTechniques.index(of: currentTechnique) {
            // This positions the scroll view to the correct cell when the screen is opened
            if didLoad == false {
                didLoad = true
                let indexToScrollTo = IndexPath(row: newIndex, section: 0)
                collectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - ScrollViewDelegate
extension TechniqueDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard collectionView.visibleCells.count > 0, let currentCell = collectionView.visibleCells[0] as? TechniqueDetailsCell else {
            return
        }
        if collectionView.visibleCells.count == 1 && technique != currentCell.technique {
            self.technique = currentCell.technique
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // disable scrolling so that the user can only scroll one page at a time
        scrollView.isScrollEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = collectionView.collectionViewLayout.targetContentOffset(forProposedContentOffset: scrollView.contentOffset)
        if offset != scrollView.contentOffset {
            scrollView.setContentOffset(offset, animated: true)
        }else{
            updateContinuousScrollIfNeeded()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateContinuousScrollIfNeeded()
        
    }
    
    // MARK: - Scrolling delegate helpers
    func updateContinuousScrollIfNeeded() {
        guard let cellIndex = self.collectionView.indexPath(for: self.collectionView.visibleCells.first!)
            else { return }
        if (cellIndex as NSIndexPath).row == 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: allTechniques.count - 2, section: 0), at: .centeredHorizontally, animated: false)
        }else if (cellIndex as NSIndexPath).row == allTechniques.count - 1 {
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        // add a small delay so that we finish the jump above before the user can shift to the next technique
        self.perform(#selector(TechniqueDetailViewController.enableScrollView), with: nil, afterDelay: 0.2)
    }
    
    func enableScrollView() {
        collectionView.isScrollEnabled = true
    }
}

extension TechniqueDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [leftChevron, rightChevron]
        if collectionView.visibleCells.count > 0, let currentCell = collectionView.visibleCells[0] as? TechniqueDetailsCell {
            views.append(currentCell.addToPlaylistButton)
            views.append(currentCell)
        }
        for view in brushStack.arrangedSubviews {
            views.append(view)
        }
        
        if !(otherVC is TechniqueBrowserViewController) { views.append(videoPlayer) }
        return views
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case is UIButton :
            return [TransitionAnimationItem(mode: .slideRight, delay: 0.2, duration:  0.5)]
        case videoPlayer :
            return [TransitionAnimationItem(mode: .fade)]
        default : break
        }
        
        let count = brushStack.arrangedSubviews.count
        let delay = 0.25 / Double(count) * Double(count - view.tag - 1) + 0.5
        return [TransitionAnimationItem(mode: .slideLeft, delay: delay, duration: 0.25)]
    }
    
    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        if otherVC is TechniqueBrowserViewController { return [videoPlayer] }
        return nil
    }
    
    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        return videoPlayer
    }
    
}
