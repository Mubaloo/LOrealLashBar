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
        watchButton.setTitleColor(UIColor.hotPink, for: UIControlState())
        videoPreview.shouldRepeat = true
        videoPreview.play()
    }
    
    var technique: Technique? {
        didSet {
            guard let technique = technique else { return }
            titleLabel.text = technique.name
            let requiredSize = titleLabel.sizeOfText(withMaxSize:CGSize(width: 257, height: CGFloat.greatestFiniteMagnitude))
            titleHeightConstraint.constant = ceil(requiredSize.height)
            detailLabel.text = technique.detail
            self.videoPreview.imposter?.image = technique.thumbnail
            let qualityOfServiceClass = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
            backgroundQueue.async(execute: {
                self.videoPreview.loadPlaylistItem(technique, shouldLoadThumb: true)
                self.videoPreview.playIfPossible()
            })
        }
    }
}
