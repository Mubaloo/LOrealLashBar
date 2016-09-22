//
//  TechniqueCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var watchButton: UIButton!
    @IBOutlet var videoPreview: AVPlayerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        watchButton.setTitleColor(UIColor.hotPink, forState: .Normal)
        videoPreview.shouldRepeat = true
        videoPreview.play()
    }
    
    var technique: Technique? {
        didSet {
            guard let technique = technique else { return }
            titleLabel.text = technique.name
            detailLabel.text = technique.detail
            videoPreview.loadPlaylistItem(technique, shouldLoadThumb: true)
            videoPreview.playIfPossible()
        }
    }
}