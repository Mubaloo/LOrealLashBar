//
//  AttractModeViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 16/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AttractModeViewController: BaseViewController {

    @IBOutlet var brushButton: UIButton!
    @IBOutlet var techniqueButton: UIButton!
    
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet var browseByLabels: [UILabel]!
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Color scheme
        view.backgroundColor = UIColor.lightBG
        for label in browseByLabels { label.textColor = UIColor.hotPink }
        for button in [brushButton, techniqueButton] {
            button.setTitleColor(UIColor.hotPink, forState: .Normal)
        }
        
        // TODO: this will eventually be replaced with a nightly-updated web service
        let service = TextFileService()
        service.populateDatabase({ error in
            if let error = error {
                self.reportError("Error", message: "Could not populate database: \(error)")
            } else {
                CoreDataStack.shared.managedObjectContext.catalogueAllManagedObjects()
            }
        })
        
        setupVideoPlayer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tbvc = segue.destinationViewController as? TitleBarViewController {
            guard let button = sender as? UIButton else { return }
            switch button {
            case brushButton : tbvc.setBrowserType(.Lashes)
            case techniqueButton : tbvc.setBrowserType(.Technique)
            default : break
            }
        }
    }
    
    func setupVideoPlayer() {
        let moviePath = NSBundle.mainBundle().pathForResource("01. CUSTOM FITTING THUMB", ofType: "mov")
        if let path = moviePath {
            let url = NSURL.fileURLWithPath(path)
            player = AVPlayer(URL: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.showsPlaybackControls = false
            playerViewController.player = player
            playerViewController.view.frame = UIScreen.mainScreen().bounds
            playerViewController.view.backgroundColor = UIColor.clearColor()
            self.view.insertSubview(playerViewController.view, atIndex: 0)
            self.addChildViewController(playerViewController)
            loopVideo()
        }
    }
    
    func loopVideo() {
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            self.player.seekToTime(kCMTimeZero)
            self.player.play()
        }
    }
    
    @IBAction func browserChosen(sender: UIButton) {
        performSegueWithIdentifier("ExitAttractMode", sender: sender)
    }
    
}

extension AttractModeViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var allViews = browseByLabels as [UIView]
        allViews.appendContentsOf(titleLabels as [UIView])
        allViews.appendContentsOf([brushButton, techniqueButton])
        return allViews
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if view is UILabel {
            return [TransitionAnimationItem(mode: .Fade, delay: 0, duration: 0.5)]
        }
        
        if view is TransitionAnimatable {
            return [TransitionAnimationItem(mode: .Native, delay: 0.5, duration: 0.5)]
        }
        
        return nil
    }
    
}
