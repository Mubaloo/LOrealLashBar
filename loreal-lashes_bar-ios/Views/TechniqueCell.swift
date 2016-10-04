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
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
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
            let requiredSize = titleLabel.sizeOfText(withMaxSize:CGSizeMake(257, CGFloat.max))
            titleHeightConstraint.constant = ceil(requiredSize.height)
            detailLabel.text = technique.detail
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                self.videoPreview.loadPlaylistItem(technique, shouldLoadThumb: true)
                self.videoPreview.playIfPossible()
            })
        }
    }
}