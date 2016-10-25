//
//  AVSharedPlayerView.swift
//  loreal-brush_bar-ios
//
//  Created by Igor Nakonetsnoi on 17/10/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import UIKit


class AVSharedPlayerView: UIView {
    
    var playerView: AVPlayerView = {
        let player = AVPlayerView.newFromNib()
        player.shouldInterruptTimeout = true
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    static let sharedInstance : AVSharedPlayerView = {
        let instance = AVSharedPlayerView()
        instance.translatesAutoresizingMaskIntoConstraints = false
        return instance
    }()
    
    private init() {
        super.init(frame: CGRect.zero)
        setupPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayer() {
        
        addSubview(playerView)
        let topConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: playerView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
    }
    
    func cleanUp() {
        playerView.cleanup()
    }
}
