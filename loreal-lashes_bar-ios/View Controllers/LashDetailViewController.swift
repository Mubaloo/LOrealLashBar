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
    @IBOutlet weak var typesLabel: UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Prepare default brush data
        updateLashData()
        updateButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoView?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoView?.pause()
    }
    
    fileprivate func updateLashData() {
        if isViewLoaded == false { return }
        guard let lash = lash else { return }
        
        videoView.loadPlaylistItem(lash)
        lengthTitleLabel.text = lash.length
        nameLabel.text = lash.name
        detailLabel.text = lash.detail
        hotTipLabel.text = lash.hotTips
        
        let categoriesArray = Array(lash.categories!)
        let categoryNames = categoriesArray.map{ ( item: LashCategory) -> String in
            return item.name
        }
        typesLabel.text = "Good for: \(categoryNames.joined(separator: ", "))"
        
        leftLashImageView.image = UIImage(cgImage: (lash.image.cgImage)!, scale: 1.0, orientation: .upMirrored)
        rightLashImageView.image = lash.image
    }
    
    fileprivate func updateButtons() {
        guard let lash = lash , isViewLoaded else { return }
        addToPlaylistButton.isUserInteractionEnabled = !lash.inPlaylist
        if lash.inPlaylist {
            addToPlaylistButton.setTitle("ADDED!", for: UIControlState())
            addToPlaylistButton.isEnabled = false
        } else {
            addToPlaylistButton.setTitle("ADD TO PLAYLIST", for: UIControlState())
            addToPlaylistButton.isEnabled = true
        }
    }
    
    // MARK:- User Interaction
    
    @IBAction func addToPlaylistTouched(_ sender: UIButton) {
        // Add the selected brush to the playlist if it's not there already.
        guard let brush = lash , !brush.inPlaylist else { return }
        brush.inPlaylist = true
        CoreDataStack.shared.saveContext()
        updateButtons()
    }
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension LashDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return [videoView, nameLabel, detailLabel, typeContainer, addToPlaylistButton, hotTipStackView, hotTipHeart, hotTipBorder]
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case videoView :
            let fade = TransitionAnimationItem(mode: .fade, duration: 0.5)
            let scale = TransitionAnimationItem(mode: .scale, duration: 0.4, quantity: 1.3)
            return [fade, scale]
            
        case nameLabel, detailLabel, typeContainer :
            return [TransitionAnimationItem(mode: .slideLeft, delay: 0.6, duration: 0.3)]
            
        case addToPlaylistButton :
            let fade = TransitionAnimationItem(mode: .fade, delay: 0.7, duration: 0.3)
            let slide = TransitionAnimationItem(mode: .slideLeft, delay: 0.7, duration: 0.3)
            return [fade, slide]
            
        case hotTipStackView, hotTipHeart :
            return [TransitionAnimationItem(mode: .fade, delay: 0.5, duration: 0.5)]
            
        case hotTipBorder :
            return [TransitionAnimationItem(mode: .native, delay: 0.5, duration: 0.5)]
            
        default: return nil
        }
    }
    
    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        if otherVC is LashesBrowserViewController { return [lashesImagesContainerView] }
        return nil
    }
    
    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        return lashesImagesContainerView
    }
}
