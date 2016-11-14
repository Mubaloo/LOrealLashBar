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
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
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
            
            // had to override the default videoplayer because it was causing a grey screen issue after loading the videos several times.
            weak var weakSelf = self
            let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                                qos: .background,
                                                target: nil)
            backgroundQueue.async {
                weakSelf?.player = AVPlayer(playerItem: AVPlayerItem(url: item.localMediaThumbURL))
                weakSelf?.playerLayer = AVPlayerLayer(player: nil)
                weakSelf?.playerLayer?.videoGravity = AVLayerVideoGravityResize
                DispatchQueue.main.async {
                    weakSelf?.playerLayer?.frame = CGRect(x: 0, y: 0, width: 308, height: 174)
                    weakSelf?.contentView.layer.addSublayer((weakSelf?.playerLayer!)!)
                }
            }
    
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(TechniqueCell.playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerLayer?.player?.currentItem)
            self.playerView.imposter?.image = item.thumbnail
        }
    }
    
    func startPlayer() {
        playerLayer?.player = player
        playerLayer?.player?.play()
        self.playerView.isHidden = true
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.playerLayer?.player?.seek(to: kCMTimeZero)
        self.playerLayer?.player?.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playerView.isHidden = false
        cleanup()
    }
    
    deinit {
        cleanup()
    }
    
    private func cleanup() {
        NotificationCenter.default.removeObserver(self)
        playerLayer?.player?.currentItem?.asset.cancelLoading()
        playerLayer?.player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
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
