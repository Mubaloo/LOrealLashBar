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
    func cellWantsToBeRemoved(cell: MyPlaylistCell)
}

class MyPlaylistCell: UICollectionViewCell {
    
    @IBOutlet var playerView: AVPlayerView!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var zigzag: UIImageView!
    
    weak var delegate: PlaylistCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.textColor = UIColor.hotPink
        categoryLabel.textColor = UIColor.hotPink
        removeButton.setTitleColor(UIColor.hotPink, forState: .Normal)
        
        playerView.shouldRepeat = true
        playerView.delegate = self
    }
    
    @IBAction func removeTouched(sender: UIButton) {
        delegate?.cellWantsToBeRemoved(self)
    }
    
    var item: PlaylistItem? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = item.name
            
            if let brush = item as? Lash {
                numberLabel.text = brush.numberString
                categoryLabel.text = brush.category?.name
                zigzag.hidden = false
            } else {
                numberLabel.text = "Technique"
                categoryLabel.text = ""
                zigzag.hidden = true
            }
            
            playerView.loadPlaylistItem(item)
        }
    }
    
}

extension MyPlaylistCell: AVPlayerViewDelegate {
    
    func playerIsReady(player: AVPlayerView) {
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