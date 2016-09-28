//
//  BrushDetailViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class LashDetailViewController: BaseViewController {
    
    @IBOutlet var videoView: AVPlayerView!
    
    @IBOutlet weak var lengthTitleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var typeContainer: UIView!
    
    @IBOutlet var hotTipStackView: UIStackView!
    @IBOutlet var hotTipLabel: UILabel!
    @IBOutlet var hotTipTitle: UILabel!
    @IBOutlet var hotTipHeart: UIImageView!
    @IBOutlet var hotTipBorder: AnimatedBorderView!
    
    @IBOutlet weak var leftLashImageView: UIImageView!
    @IBOutlet weak var rightLashImageView: UIImageView!
    @IBOutlet var addToPlaylistButton: UIButton!
    @IBOutlet weak var lashesImagesContainerView: UIView!

    var lash: Lash? {
        didSet {
            updateLashData()
            updateButtons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Videos on this screen should prevent a timeout
        videoView.shouldInterruptTimeout = true
        hotTipBorder.titleWidth = 34
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
        hotTipTitle.textColor = UIColor.hotPink
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Prepare default brush data
        updateLashData()
        updateButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        videoView?.play()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        videoView?.pause()
    }
    
    private func updateLashData() {
        if isViewLoaded() == false { return }
        guard let lash = lash else { return }
        
        videoView.loadPlaylistItem(lash)
        lengthTitleLabel.text = lash.length
        nameLabel.text = lash.name
        detailLabel.text = lash.detail
        hotTipLabel.text = lash.hotTips
        
        leftLashImageView.image = lash.image
        rightLashImageView.image = lash.image
    }
    
    private func updateButtons() {
        guard let lash = lash where isViewLoaded() else { return }
        addToPlaylistButton.userInteractionEnabled = !lash.inPlaylist
        if lash.inPlaylist {
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

extension LashDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return [videoView, nameLabel, detailLabel, typeContainer, addToPlaylistButton, hotTipStackView, hotTipHeart, hotTipBorder]
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case videoView :
            let fade = TransitionAnimationItem(mode: .Fade, duration: 0.5)
            let scale = TransitionAnimationItem(mode: .Scale, duration: 0.4, quantity: 1.3)
            return [fade, scale]
            
        case nameLabel, detailLabel, typeContainer :
            return [TransitionAnimationItem(mode: .SlideLeft, delay: 0.6, duration: 0.3)]
            
        case addToPlaylistButton :
            let fade = TransitionAnimationItem(mode: .Fade, delay: 0.7, duration: 0.3)
            let slide = TransitionAnimationItem(mode: .SlideLeft, delay: 0.7, duration: 0.3)
            return [fade, slide]
            
        case hotTipStackView, hotTipHeart :
            return [TransitionAnimationItem(mode: .Fade, delay: 0.5, duration: 0.5)]
            
        case hotTipBorder :
            return [TransitionAnimationItem(mode: .Native, delay: 0.5, duration: 0.5)]
            
        default: return nil
        }
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if otherVC is LashesBrowserViewController { return [lashesImagesContainerView] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return lashesImagesContainerView
    }
}