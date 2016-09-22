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
    func playerIsReady(player: AVPlayerView)
    
    /** Sent when the player detects that a given chapter has been entered, or nil if no chapter is currently valid. Optional. */
    func player(player: AVPlayerView, didEnterChapterIndex index: Int?)
    
    /** Sent when the end of the content is reached. Optional. */
    func playerDidFinishPlaying(player: AVPlayerView)
    
    /** Sent when the player has processed the chapter data. Optional. */
    func playerDidRetrieveChapterData(dataArray: [[String : AnyObject]])
}

extension AVPlayerViewDelegate {
    func playerIsReady(player: AVPlayerView) {}
    func player(player: AVPlayerView, didEnterChapterIndex index: Int?) {}
    func playerDidFinishPlaying(player: AVPlayerView) {}
    func playerDidRetrieveChapterData(dataArry: [[String : AnyObject]]) {}
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
    
    private var playerLayer: AVPlayerLayer { get { return self.layer as! AVPlayerLayer } }
    private var chapterOffsets: [NSTimeInterval]?
    private var chapterObserver: AnyObject?
    private var player: AVPlayer { get { return playerLayer.player! } }
    
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
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    deinit {
        player.pause()
        player.removeObserver(self, forKeyPath: "rate")
        player.removeObserver(self, forKeyPath: "status")
    }
    
    /** Creates a new AVPlayerView with all required controls using the standard nib. */
    class func newFromNib() -> AVPlayerView {
        let nib = UINib(nibName: "AVPlayerView", bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil)[0] as! AVPlayerView
    }
    
    private func setUpPlayer() {
        let player = AVPlayer()
        let oneSecond = CMTimeMake(1, 60)
        
        player.addPeriodicTimeObserverForInterval(
            oneSecond, queue: dispatch_get_main_queue(),
            usingBlock: { [weak self] time in
                if let timeLabel = self?.timeLabel {
                    let seconds = Int(floor(time.seconds % 60))
                    let minutes = Int(floor(time.seconds / 60))
                    timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
                }
                if let progressBar = self?.progressBar {
                    let duration = player.currentItem?.duration ?? CMTimeMake(0, 1)
                    progressBar.progress = Float(time.seconds / duration.seconds)
                }
            })
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
        player.addObserver(self, forKeyPath: "rate", options: [.Old, .New], context: nil)
        player.addObserver(self, forKeyPath: "status", options: [.Old, .New], context: nil)
        player.muted = NSUserDefaults.videoMuted
        
        playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravityResize
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        muteButton?.selected = player.muted
    }
    
    // We override this method so that the imposter can be made temporarily visible
    // before the snapshot is taken, assuming it isn't already.
    override func snapshot() -> UIImage {
        if imposter?.hidden == false { return super.snapshot() }
        imposter?.hidden = false
        let image = super.snapshot()
        imposter?.hidden = true
        return image
    }
    
    // MARK:- Loading Assets
    
    func loadPlaylistItem(item: PlaylistItem, chapterOffsets: [NSTimeInterval]? = nil) {
        self.loadPlaylistItem(item, chapterOffsets: chapterOffsets, shouldLoadThumb: false)
    }
    
    func loadPlaylistItem(item: PlaylistItem, chapterOffsets: [NSTimeInterval]? = nil, shouldLoadThumb: Bool) {
        
        imposter?.image = item.thumbnail
        imposter?.hidden = self.player.status == .ReadyToPlay ? true : false
        if shouldLoadThumb == true {
            loadURL(item.localMediaThumbURL, chapterOffsets: chapterOffsets)
        }else{
            loadURL(item.localMediaURL, chapterOffsets: chapterOffsets)
        }
    }
    
    func playIfPossible() {
        if self.player.status == .ReadyToPlay {
            self.player.play()
        }
    }
    
    func loadURL(url: NSURL, chapterOffsets: [NSTimeInterval]? = nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let item = AVPlayerItem(URL: url)
            let chapterOffsetsNew = self.loadChapterDataFromAsset(item.asset)
            self.player.replaceCurrentItemWithPlayerItem(item)
            self.setChaptersAtTimeIntervals(chapterOffsetsNew)
        })
    }
    
    func loadChapterDataFromAsset(asset: AVAsset) -> [NSTimeInterval]? {
        let keys = [AVMetadataCommonKeyTitle]
        let chapters = asset.chapterMetadataGroupsWithTitleLocale(NSLocale.currentLocale(), containingItemsWithCommonKeys: keys)
        var chapterData: [[String : AnyObject]] = []
        var chapterTimes: [NSTimeInterval] = []
        for metadataGroup in chapters {
            let items = metadataGroup.items
            for metadataItem in items {
                guard let key = metadataItem.commonKey, let value = metadataItem.value else{
                    continue
                }
                if key == AVMetadataCommonKeyTitle {
                    let time = CMTimeGetSeconds(metadataGroup.timeRange.start)
                    chapterData.append(["name": value, "time_offset": time])
                    chapterTimes.append(time)
                }
            }
        }
        delegate?.playerDidRetrieveChapterData(chapterData)
        return chapterTimes.count > 0 ? chapterTimes : nil
    }
    
    // MARK:- Controlling Playback
    
    func setTimeOffset(offset: NSTimeInterval) {
        player.seekToTime(CMTimeMake(Int64((offset + 0.00001) * 1000000), 1000000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimePositiveInfinity)
        if player.rate == 0 { togglePlay(self) }
    }
    
    func play() {
        if player.rate == 0 { togglePlay(self) }
    }
    
    func pause() {
        if player.rate != 0 { togglePlay(self) }
    }
    
    func mute() {
        if !player.muted { player.muted = true }
    }
    
    func unmute() {
        if player.muted { player.muted = false }
    }
    
    @IBAction func reset() {
        player.rate = 0
        player.seekToTime(CMTimeMake(0, 1))
        delegate?.player(self, didEnterChapterIndex: nil)
    }
    
    @IBAction func togglePlay(sender: AnyObject) {
        if player.rate == 0 {
            if player.currentTime() == player.currentItem?.duration { reset() }
            informDelegateOfChapterChange()
            player.rate = rate
        } else {
            player.rate = 0
        }
    }
    
    @IBAction func toggleMute(sender: AnyObject) {
        player.muted = !player.muted
        muteButton?.selected = player.muted
        NSUserDefaults.videoMuted = player.muted
    }
    
    // Connect this to a pan gesture to enable scrubbing
    @IBAction func videoScrubbing(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Possible, .Cancelled, .Failed :
            togglePlay(self)
            return
        default: break
        }
        
        guard let view = sender.view else { return }
        let location = sender.locationInView(view)
        let progress = location.x / view.bounds.width
        let duration = player.currentItem?.duration.seconds ?? 0
        let time = CMTimeMake(Int64(duration * Double(progress) * 10), 10)
        player.seekToTime(time)
        
        if sender.state == .Began { player.rate = 0 }
        if sender.state == .Ended { togglePlay(sender) }
    }
    
    // MARK:- Update Display for Rate and Status Changes
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // If the player's rate changes it may have been paused or reached the end.
        if keyPath == "rate" {
            
            // Update the play / pause button to show the right image
            let isPlaying = (player.rate != 0)
            playPauseButton?.selected = isPlaying
            let app = UIApplication.sharedApplication() as! TimeOutApplication
            
            // Only update the timeout if the value has changed from or to zero, not just speed
            let old = change![NSKeyValueChangeOldKey] as! NSNumber
            let new = change![NSKeyValueChangeNewKey] as! NSNumber
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
                        player.seekToTime(kCMTimeZero)
                        togglePlay(self)
                    } else {
                        delegate?.playerDidFinishPlaying(self)
                    }
                }
            }
            
            // Show or hide the big play button
            let playAlpha: CGFloat = isPlaying ? 0 : 1
            UIView.animateWithDuration(0.25, animations: { self.bigPlayButton?.alpha = playAlpha })
        }
        
        // If status changes, it could mean that the player is now ready to rock.
        else if keyPath == "status" {
            let old = change![NSKeyValueChangeOldKey] as! NSNumber
            let new = change![NSKeyValueChangeNewKey] as! NSNumber
            let wasReady = (old.integerValue == AVPlayerStatus.ReadyToPlay.rawValue)
            let isReady = (new.integerValue == AVPlayerStatus.ReadyToPlay.rawValue)
            if wasReady == isReady { return }
            imposter?.hidden = isReady
            if isReady { delegate?.playerIsReady(self) }
        }
    }
    
    // MARK:- Chapters
    
    private func setChaptersAtTimeIntervals(chapterOffsets: [NSTimeInterval]?) {
        let sorted = chapterOffsets?.sort()
        self.chapterOffsets = sorted
        
        // Remove the existing chapters if necessary
        if let chapterObserver = chapterObserver {
            player.removeTimeObserver(chapterObserver)
            self.chapterObserver = nil
        }
        
        // Add the new chapters
        guard let sortedTimes = sorted else { return }
        
        // * 1000000 and divide by the same to alow using decimals in the chapter times
        let times = sortedTimes.map({ NSValue(CMTime: CMTimeMake(Int64($0 * 1000000) , 1000000)) })
        
        chapterObserver = player.addBoundaryTimeObserverForTimes(
            times, queue: dispatch_get_main_queue(),
            usingBlock: { [weak self] in self?.informDelegateOfChapterChange() }
        )
    }
    
    private func informDelegateOfChapterChange() {
        guard let chapterOffsets = chapterOffsets else { return }
        let seconds = player.currentTime().seconds
        if let chapterTime = chapterOffsets.filter({ $0 <= seconds }).last,
            chapterIndex = chapterOffsets.indexOf(chapterTime) {
            delegate?.player(self, didEnterChapterIndex: chapterIndex)
        }
    }
    
}