//
//  BrushDetailViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class BrushDetailViewController: BaseViewController {
    
    @IBOutlet var videoView: AVPlayerView!
    @IBOutlet var basicDataStack: UIStackView!
    
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var hotTipStackView: UIStackView!
    @IBOutlet var hotTipLabel: UILabel!
    @IBOutlet var hotTipTitle: UILabel!
    @IBOutlet var hotTipHeart: UIImageView!
    @IBOutlet var hotTipBorder: AnimatedBorderView!
    
    @IBOutlet var brushImage: UIImageView!
    @IBOutlet var bestSellerViews: [UIView]!
    @IBOutlet var addToPlaylistButton: UIButton!
    @IBOutlet var viewPlaylistButton: UIButton!
    
    @IBOutlet var productMessage: UILabel!
    @IBOutlet var productContainer: UIView!
    @IBOutlet var productCollection: UICollectionView!
    
    var lash: Lash? {
        didSet {
            associates = lash?.orderedAssociates()
            updateBrushData()
            updateButtons()
        }
    }
    
    var associates: [Product]? {
        didSet {
            if !isViewLoaded() { return }
            productCollection.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Videos on this screen should prevent a timeout
        videoView.shouldInterruptTimeout = true
        hotTipBorder.titleWidth = 34
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
        numberLabel.textColor = UIColor.hotPink
        categoryLabel.textColor = UIColor.hotPink
        hotTipTitle.textColor = UIColor.hotPink
        productMessage.textColor = UIColor.hotPink
        
        for view in bestSellerViews {
            if let label = view as? UILabel {
                label.textColor = UIColor.hotPink
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Prepare default brush data
        updateBrushData()
        updateButtons()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        videoView?.pause()
    }
    
    private func updateBrushData() {
        if isViewLoaded() == false { return }
        guard let brush = lash else { return }
        
        videoView.loadPlaylistItem(brush)
        numberLabel.text = brush.numberString
        categoryLabel.text = brush.category?.name
        nameLabel.text = brush.name
        detailLabel.text = brush.detail
        hotTipLabel.text = brush.hotTips
        
        for view in bestSellerViews {
            view.hidden = (brush.bestSeller == false)
        }
        
        brushImage.image = brush.image.rotate()
    }
    
    private func updateButtons() {
        guard let brush = lash where isViewLoaded() else { return }
        addToPlaylistButton.userInteractionEnabled = !brush.inPlaylist
        if brush.inPlaylist {
            addToPlaylistButton.setTitle("ADDED!", forState: .Normal)
            addToPlaylistButton.enabled = false
        } else {
            addToPlaylistButton.setTitle("ADD TO PLAYLIST", forState: .Normal)
            addToPlaylistButton.enabled = true
        }
    }
    
    // MARK:- User Interaction
    
    @IBAction func addToPlaylistTouched(sender: UIButton) {
        // Add the selected brush to the playlist if it's not there already.
        guard let brush = lash where !brush.inPlaylist else { return }
        brush.inPlaylist = true
        CoreDataStack.shared.saveContext()
        updateButtons()
    }
    
    @IBAction func closeButtonTouched(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension BrushDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return [videoView, basicDataStack, detailLabel, brushImage, addToPlaylistButton, viewPlaylistButton, hotTipStackView, hotTipHeart, hotTipBorder, productContainer]
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case videoView :
            let fade = TransitionAnimationItem(mode: .Fade, duration: 0.5)
            let scale = TransitionAnimationItem(mode: .Scale, duration: 0.4, quantity: 1.3)
            return [fade, scale]
            
        case basicDataStack, detailLabel :
            return [TransitionAnimationItem(mode: .SlideLeft, delay: 0.6, duration: 0.3)]
            
        case brushImage :
            let fade = TransitionAnimationItem(mode: .Fade, delay: 0.5, duration: 0.3)
            let slide = TransitionAnimationItem(mode: .SlideLeft, delay: 0.5, duration: 0.3)
            return [fade, slide]
            
        case addToPlaylistButton :
            let fade = TransitionAnimationItem(mode: .Fade, delay: 0.7, duration: 0.3)
            let slide = TransitionAnimationItem(mode: .SlideLeft, delay: 0.7, duration: 0.3)
            return [fade, slide]
            
        case viewPlaylistButton :
            let fade = TransitionAnimationItem(mode: .Fade, delay: 0.65, duration: 0.3)
            let slide = TransitionAnimationItem(mode: .SlideLeft, delay: 0.65, duration: 0.3)
            return [fade, slide]
            
        case hotTipStackView, hotTipHeart :
            return [TransitionAnimationItem(mode: .Fade, delay: 0.5, duration: 0.5)]
            
        case hotTipBorder :
            return [TransitionAnimationItem(mode: .Native, delay: 0.5, duration: 0.5)]
            
        case productContainer :
            return [TransitionAnimationItem(mode: .SlideBottom, delay: 0.5, duration: 0.5, quantity: view.frame.height)]
            
        default: return nil
        }
    }
    
}

extension BrushDetailViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return associates?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath)
        if let productCell = cell as? ProductCell,
            product = associates?[indexPath.item] {
            productCell.nameLabel.text = product.name
            productCell.imageView.image = product.image
        }
        return cell
    }
    
}