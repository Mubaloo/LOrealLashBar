//
//  AVPlayerView.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 26/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import AVFoundation

protocol AVPlayerViewDelegate: class {
    /** Sent when the player has loaded its video. Optional. */
    func playerIsReady(_ player: AVPlayerView)
    
    /** Sent when the player detects that a given chapter has been entered, or nil if no chapter is currently valid. Optional. */
    func player(_ player: AVPlayerView, didEnterChapterIndex index: Int?)
    
    /** Sent when the end of the content is reached. Optional. */
    func playerDidFinishPlaying(_ player: AVPlayerView)
    
    /** Sent when the player has processed the chapter data. Optional. */
    func playerDidRetrieveChapterData(_ dataArray: [[String : AnyObject]])
}

extension AVPlayerViewDelegate {
    func playerIsReady(_ player: AVPlayerView) {}
    func player(_ player: AVPlayerView, didEnterChapterIndex index: Int?) {}
    func playerDidFinishPlaying(_ player: AVPlayerView) {}
    func playerDidRetrieveChapterData(_ dataArry: [[String : AnyObject]]) {}
}

/**
 This view encapsulates an AVPlayerLayer and hooks for custom control elements that allow
 the user to control its playback. It also provides a thumbnail that displays while the
 video itself is loading to prevent a 'blank' square flashing up on loading and to ensure
 that something sensible is shown when a snapshot is taken of the view.
 */

class AVPlayerView: UIView {
    
    /** The thumbnail that replaces the video when it is not loaded and during transitions. */
    @IBOutlet var imposter: UIImageView?
    
    /** A large play button displayed centrally on the screen while the video is paused. */
    @IBOutlet var bigPlayButton: UIButton?
    
    /** A small play/pause button that is always visible. Unselected = Play, Selected = Pause */
    @IBOutlet var playPauseButton: UIButton?
    
    /** A progress bar displaying current progress through the video. */
    @IBOutlet var progressBar: UIProgressView?
    
    /** A label depicting the current time in minutes and seconds. */
    @IBOutlet var timeLabel: UILabel?
    
    /** A small mute/unmute button that is always visible. Unselected = Mute, Selected = Unmute */
    @IBOutlet var muteButton: UIButton?
    
    weak var delegate: AVPlayerViewDelegate?
    
    fileprivate var playerLayer: AVPlayerLayer { get { return self.layer as! AVPlayerLayer } }
    fileprivate var chapterOffsets: [TimeInterval]?
    fileprivate var chapterObserver: AnyObject?
    fileprivate var player: AVPlayer { get { return playerLayer.player! } }
    
    /** The status of the encapsulated AVPlayer */
    var status: AVPlayerStatus { get { return player.status } }
    
    /** Set true if the video should repeat when it reaches the end. */
    var shouldRepeat = false
    
    /** 
     Set true if the app timeout should be suspended while the video is playing. This is typically
     true for videos that the user interacts with directly, and false for those that play automatically
     and in fast-forward (i.e. in the Playlist screen).
     */
    var shouldInterruptTimeout = false
    
    /** The speed at which the video should play. */
    var rate: Float = 1 {
        didSet {
            if player.rate == 0 { return }
            player.rate = rate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpPlayer()
    }
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    deinit {
        player.pause()
        player.removeObserver(self, forKeyPath: "rate")
        player.removeObserver(self, forKeyPath: "status")
    }
    
    func cleanup() {
        self.player.replaceCurrentItem(with: nil)
        imposter?.isHidden = false
        imposter?.image = nil
    }

    /** Creates a new AVPlayerView with all required controls using the standard nib. */
    class func newFromNib() -> AVPlayerView {
        let nib = UINib(nibName: "AVPlayerView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! AVPlayerView
    }
    
    fileprivate func setUpPlayer() {
        let player = AVPlayer()
        let oneSecond = CMTimeMake(1, 60)
        
        player.addPeriodicTimeObserver(
            forInterval: oneSecond, queue: DispatchQueue.main,
            using: { [weak self] time in
                if let timeLabel = self?.timeLabel {
                    let seconds = Int(floor(time.seconds.truncatingRemainder(dividingBy: 60)))
                    let minutes = Int(floor(time.seconds / 60))
                    timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
                }
                if let progressBar = self?.progressBar {
                    let duration = player.currentItem?.duration ?? CMTimeMake(0, 1)
                    progressBar.progress = Float(time.seconds / duration.seconds)
                }
            })
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.pause
        player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        player.isMuted = UserDefaults.videoMuted
        
        playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravityResize
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        muteButton?.isSelected = player.isMuted
    }
    
    // We override this method so that the imposter can be made temporarily visible
    // before the snapshot is taken, assuming it isn't already.
    override func snapshot() -> UIImage {
        if imposter?.isHidden == false { return super.snapshot() }
        imposter?.isHidden = false
        let image = super.snapshot()
        imposter?.isHidden = true
        return image
    }
    
    // MARK:- Loading Assets
    
    func loadPlaylistItem(_ item: PlaylistItem) {
        self.loadPlaylistItem(item, shouldLoadThumb: false)
    }
    
    func loadPlaylistItem(_ item: PlaylistItem, shouldLoadThumb: Bool) {
        if shouldLoadThumb == true {
            loadURL(item.localMediaThumbURL as URL)
        }else{
            loadURL(item.localMediaURL as URL)
        }
    }
    
    func playIfPossible() {
        if self.player.status == .readyToPlay {
            self.player.play()
            imposter?.isHidden = true
        }
    }
    
    func loadURL(_ url: URL) {
            let item = AVPlayerItem(url: url)
            let chapterOffsetsNew = self.loadChapterDataFromAsset(item.asset)
            self.player.replaceCurrentItem(with: item)
            self.setChaptersAtTimeIntervals(chapterOffsetsNew)
    }
    
    func loadChapterDataFromAsset(_ asset: AVAsset) -> [TimeInterval]? {
        let keys = [AVMetadataCommonKeyTitle]
        let chapters = asset.chapterMetadataGroups(withTitleLocale: Locale.current, containingItemsWithCommonKeys: keys)
        var chapterData: [[String : AnyObject]] = []
        var chapterTimes: [TimeInterval] = []
        for metadataGroup in chapters {
            let items = metadataGroup.items
            for metadataItem in items {
                guard let key = metadataItem.commonKey, let value = metadataItem.value else{
                    continue
                }
                if key == AVMetadataCommonKeyTitle {
                    let time = CMTimeGetSeconds(metadataGroup.timeRange.start)
                    chapterData.append(["name": value, "time_offset": time as AnyObject])
                    chapterTimes.append(time)
                }
            }
        }
        delegate?.playerDidRetrieveChapterData(chapterData)
        return chapterTimes.count > 0 ? chapterTimes : nil
    }
    
    // MARK:- Controlling Playback
    
    func setTimeOffset(_ offset: TimeInterval) {
        player.seek(to: CMTimeMake(Int64((offset + 0.00001) * 1000000), 1000000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimePositiveInfinity)
        if player.rate == 0 { togglePlay(self) }
    }
    
    func play() {
        if player.rate == 0 { togglePlay(self) }
        imposter?.isHidden = true
    }
    
    func pause() {
        if player.rate != 0 { togglePlay(self) }
    }
    
    func mute() {
        if !player.isMuted { player.isMuted = true }
    }
    
    func unmute() {
        if player.isMuted { player.isMuted = false }
    }
    
    @IBAction func reset() {
        player.rate = 0
        player.seek(to: CMTimeMake(0, 1))
        delegate?.player(self, didEnterChapterIndex: nil)
    }
    
    @IBAction func togglePlay(_ sender: AnyObject) {
        if player.rate == 0 {
            if player.currentTime() == player.currentItem?.duration { reset() }
            informDelegateOfChapterChange()
            player.rate = rate
        } else {
            player.rate = 0
        }
    }
    
    @IBAction func toggleMute(_ sender: AnyObject) {
        player.isMuted = !player.isMuted
        muteButton?.isSelected = player.isMuted
        UserDefaults.videoMuted = player.isMuted
    }
    
    // Connect this to a pan gesture to enable scrubbing
    @IBAction func videoScrubbing(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .possible, .cancelled, .failed :
            togglePlay(self)
            return
        default: break
        }
        
        guard let view = sender.view else { return }
        let location = sender.location(in: view)
        let progress = location.x / view.bounds.width
        let duration = player.currentItem?.duration.seconds ?? 0
        let time = CMTimeMake(Int64(duration * Double(progress) * 10), 10)
        player.seek(to: time)
        
        if sender.state == .began { player.rate = 0 }
        if sender.state == .ended { togglePlay(sender) }
    }
    
    // MARK:- Update Display for Rate and Status Changes
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // If the player's rate changes it may have been paused or reached the end.
        if keyPath == "rate" {
            
            // Update the play / pause button to show the right image
            let isPlaying = (player.rate != 0)
            playPauseButton?.isSelected = isPlaying
            let app = UIApplication.shared as! TimeOutApplication
            
            // Only update the timeout if the value has changed from or to zero, not just speed
            let old = change![NSKeyValueChangeKey.oldKey] as! NSNumber
            let new = change![NSKeyValueChangeKey.newKey] as! NSNumber
            if (old.floatValue != 0) == (new.floatValue != 0) { return }
            if isPlaying {
                if shouldInterruptTimeout {
                    app.pauseTimeout()
                }
            } else {
                if shouldInterruptTimeout {
                    app.resumeTimeout()
                }
                
                let duration = player.currentItem?.duration ?? CMTimeMake(0, 1)
                if player.currentTime().seconds >= duration.seconds {
                    if shouldRepeat {
                        player.seek(to: kCMTimeZero)
                        togglePlay(self)
                    } else {
                        delegate?.playerDidFinishPlaying(self)
                    }
                }
            }
            
            // Show or hide the big play button
            let playAlpha: CGFloat = isPlaying ? 0 : 1
            UIView.animate(withDuration: 0.25, animations: { self.bigPlayButton?.alpha = playAlpha })
        }
        
        // If status changes, it could mean that the player is now ready to rock.
        else if keyPath == "status" {
            let old = change![NSKeyValueChangeKey.oldKey] as! NSNumber
            let new = change![NSKeyValueChangeKey.newKey] as! NSNumber
            let wasReady = (old.intValue == AVPlayerStatus.readyToPlay.rawValue)
            let isReady = (new.intValue == AVPlayerStatus.readyToPlay.rawValue)
            if wasReady == isReady { return }
            if isReady { delegate?.playerIsReady(self) }
        }
    }
    
    // MARK:- Chapters
    
    fileprivate func setChaptersAtTimeIntervals(_ chapterOffsets: [TimeInterval]?) {
        let sorted = chapterOffsets?.sorted()
        self.chapterOffsets = sorted
        
        // Remove the existing chapters if necessary
        if let chapterObserver = chapterObserver {
            player.removeTimeObserver(chapterObserver)
            self.chapterObserver = nil
        }
        
        // Add the new chapters
        guard let sortedTimes = sorted else { return }
        
        // * 1000000 and divide by the same to alow using decimals in the chapter times
        let times = sortedTimes.map({ NSValue(time: CMTimeMake(Int64($0 * 1000000) , 1000000)) })
        
        chapterObserver = player.addBoundaryTimeObserver(
            forTimes: times, queue: DispatchQueue.main,
            using: { [weak self] in self?.informDelegateOfChapterChange() }
        ) as AnyObject?
    }
    
    fileprivate func informDelegateOfChapterChange() {
        guard let chapterOffsets = chapterOffsets else { return }
        let seconds = player.currentTime().seconds
        if let chapterTime = chapterOffsets.filter({ $0 <= seconds }).last,
            let chapterIndex = chapterOffsets.index(of: chapterTime) {
            delegate?.player(self, didEnterChapterIndex: chapterIndex)
        }
    }
    
}
