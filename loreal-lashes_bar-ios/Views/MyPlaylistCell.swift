//
//  MyPlaylistCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlaylistCellDelegate: class {
    func cellWantsToBeRemoved(_ cell: MyPlaylistCell)
}

class MyPlaylistCell: UICollectionViewCell {
    
    @IBOutlet var playerView: AVPlayerView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    
    weak var delegate: PlaylistCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeButton.setTitleColor(UIColor.hotPink, for: UIControlState())
        
        playerView.shouldRepeat = true
        playerView.delegate = self
    }
    
    @IBAction func removeTouched(_ sender: UIButton) {
        delegate?.cellWantsToBeRemoved(self)
    }
    
    var item: PlaylistItem? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = item.name
            
            playerView.loadPlaylistItem(item)
        }
    }
    
}

extension MyPlaylistCell: AVPlayerViewDelegate {
    
    func playerIsReady(_ player: AVPlayerView) {
        player.mute()
        player.rate = 10
        player.play()
    }
    
}

class EmptyVideoCell: UICollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.textColor = UIColor.hotPink
        layer.borderWidth = 2
    }
    
}
