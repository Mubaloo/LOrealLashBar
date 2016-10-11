//
//  TechniqueCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import AVFoundation

class TechniqueCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var watchButton: UIButton!
    @IBOutlet var videoPreview: AVPlayerView!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    var playerLayer: AVPlayerLayer?
    
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
            
            // had to override the default videoplayer because it was causing a grey screen issue after loading the videos several times.
            playerLayer = AVPlayerLayer(player: AVPlayer(playerItem: AVPlayerItem(url: technique.localMediaThumbURL)))
            playerLayer?.videoGravity = AVLayerVideoGravityResize
            playerLayer?.frame = CGRect(x: self.reuseIdentifier == "TechniqueCellB" ?  325: 0, y: 0, width: 325, height: 182)
            self.contentView.layer.addSublayer(playerLayer!)
            playerLayer?.player?.play()
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(TechniqueCell.playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerLayer?.player?.currentItem)
            
            self.videoPreview.imposter?.image = technique.thumbnail
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.playerLayer?.player?.seek(to: kCMTimeZero)
        self.playerLayer?.player?.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
}
