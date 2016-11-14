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
            button?.setTitleColor(UIColor.hotPink, for: UIControlState())
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
        NotificationCenter.default.addObserver(player, selector: #selector(AVPlayer.play), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
        loopVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
        player.pause()
        NotificationCenter.default.removeObserver(player, name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tbvc = segue.destination as? TitleBarViewController {
            guard let button = sender as? UIButton else { return }
            switch button {
            case brushButton : tbvc.setBrowserType(.Lashes)
            case techniqueButton : tbvc.setBrowserType(.Technique)
            default : break
            }
        }
    }
    
    func setupVideoPlayer() {
        let moviePath = Bundle.main.path(forResource: "attract video", ofType: "mp4")
        if let path = moviePath {
            let url = URL(fileURLWithPath: path)
            player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.showsPlaybackControls = false
            playerViewController.player = player
            playerViewController.view.frame = UIScreen.main.bounds
            playerViewController.view.backgroundColor = UIColor.clear
            self.view.insertSubview(playerViewController.view, at: 0)
            self.addChildViewController(playerViewController)
        }
    }
    
    func loopVideo() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            guard let sourceItem = notification.object as? AVPlayerItem else { return }
            if sourceItem == self.player.currentItem {
                self.player.seek(to: kCMTimeZero)
                self.player.play()
            }
        }
    }
    
    @IBAction func browserChosen(_ sender: UIButton) {
        performSegue(withIdentifier: "ExitAttractMode", sender: sender)
    }
    
}

extension AttractModeViewController: TransitionAnimationDataSource {
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var allViews = browseByLabels as [UIView]
        allViews.append(contentsOf: titleLabels as [UIView])
        allViews.append(contentsOf: [brushButton, techniqueButton])
        return allViews
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if view is UILabel {
            return [TransitionAnimationItem(mode: .fade, delay: 0, duration: 0.5)]
        }
        
        if view is TransitionAnimatable {
            return [TransitionAnimationItem(mode: .native, delay: 0.5, duration: 0.5)]
        }
        
        return nil
    }
    
}
