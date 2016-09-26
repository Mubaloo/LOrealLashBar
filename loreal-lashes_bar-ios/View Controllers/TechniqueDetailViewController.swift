//
//  TechniqueDetailViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueDetailViewController: BaseViewController {
    
    @IBOutlet var videoContainer: AVPlayerView!
    
    @IBOutlet var techniqueDetailLabel: UILabel!
    @IBOutlet var brushNameLabel: UILabel!
    @IBOutlet var dataStack: UIStackView!
    
    @IBOutlet var leftChevron: UIButton!
    @IBOutlet var rightChevron: UIButton!
    @IBOutlet var addToPlaylistButton: UIButton!
    @IBOutlet var brushDetailsButton: UIButton!

    @IBOutlet var brushStack: UIStackView!
    
    var allTechniques = Technique.orderedTechniques()
    var technique: Technique? {
        didSet {
            if isViewLoaded() {
                updateChapters()
                updateTechniqueVideo()
                updateButtons()
                
                updateChapterPopover(nil)
                dataStack.crossfadeUpdate(0.5, updates: {
                    self.updateBasicData()
                })
            }
        }
    }
    
    var currentChapter: Chapter? {
        didSet {
            if isViewLoaded(){
                updateChapterPopover(oldValue)
            }
        }
    }
    
    var chapterPopoverVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        videoContainer.shouldInterruptTimeout = true
        
        // Set text with kerning
        let attribs: [String: AnyObject] = [
            NSFontAttributeName : brushDetailsButton.titleLabel!.font,
            NSForegroundColorAttributeName : UIColor.hotPink,
            NSKernAttributeName : NSNumber(int: 2)
        ]
        
        let title = NSAttributedString(string: "VIEW DETAILS", attributes: attribs)
        brushDetailsButton.setAttributedTitle(title, forState: .Normal)
        
        videoContainer.delegate = self
    
        updateBasicData()
        updateChapters()
        updateTechniqueVideo()
        
        updateChapterPopover(nil)
        updateChapterPopover(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateButtons()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let brushDetailVC = segue.destinationViewController as? LashDetailViewController,
            chapter = currentChapter ?? technique?.orderedChapters().first {
            brushDetailVC.lash = chapter.lash
        }
    }
    
    // MARK:- Update Methods
    
    private func updateTechniqueVideo() {
        guard let technique = technique else { return }
        let chapters = Array(technique.chapters ?? []).map({ $0.timeOffset as NSTimeInterval })
        videoContainer.loadPlaylistItem(technique, chapterOffsets: chapters)
    }
    
    private func updateBasicData() {
        guard let technique = technique else { return }
        
        brushNameLabel.text = technique.name
        techniqueDetailLabel.text = technique.detail
    }
    
    private func updateChapters() {
        for view in brushStack.arrangedSubviews {
            brushStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let technique = technique else { return }
        
        for (index, chapter) in technique.orderedChapters().enumerate() {
            
            let newStack = UIStackView()
            newStack.axis = .Vertical
            newStack.distribution = .EqualSpacing
            newStack.spacing = 20
            
            let titleLabel = UILabel()
            titleLabel.textColor = UIColor.whiteColor()
            titleLabel.font = UIFont(name: "HelveticaNeueCond", size: 25)
            titleLabel.text = chapter.name
            titleLabel.textAlignment = .Center
            titleLabel.numberOfLines = 2
            titleLabel.tag = index
            
            newStack.addArrangedSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.addConstraint(NSLayoutConstraint(
                item: titleLabel, attribute: .Height, relatedBy: .Equal,
                toItem: nil, attribute: .Height, multiplier: 0, constant: 110
                ))
            
            let image = chapter.lash?.image.scale(0.5)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .Top
            imageView.setContentHuggingPriority(240, forAxis: .Vertical)
            imageView.setContentCompressionResistancePriority(740, forAxis: .Vertical)
            imageView.tag = index
            
            newStack.addArrangedSubview(imageView)
            brushStack.addArrangedSubview(newStack)
        }
    }
    
    private func updateChapterPopover(oldValue: Chapter?) {
        let title = currentChapter?.lash?.name ?? technique?.name ?? "Error"
        brushNameLabel.crossfadeUpdate(0.25, updates: { self.brushNameLabel.text = title })
    }
    
    private func updateButtons() {
        guard let technique = technique where isViewLoaded() else { return }
        addToPlaylistButton.userInteractionEnabled = !technique.inPlaylist
        if technique.inPlaylist {
            addToPlaylistButton.setTitle("ADDED!", forState: .Normal)
            addToPlaylistButton.enabled = false
        } else {
            addToPlaylistButton.setTitle("ADD TO PLAYLIST", forState: .Normal)
            addToPlaylistButton.enabled = true
        }
        
        leftChevron.enabled = (technique != allTechniques.first)
        rightChevron.enabled = (technique != allTechniques.last)
    }

    // MARK:- User Interactions
    
    private func shiftTechniques(direction: Int) {
        guard let technique = technique,
            index = allTechniques.indexOf(technique)
            else { return }
        
        let newIndex = index + direction
        if newIndex < 0 || newIndex >= allTechniques.count { return }
        self.technique = allTechniques[newIndex]
    }
    
    @IBAction func scrollLeft(sender: UIButton) {
        shiftTechniques(-1)
    }
    
    @IBAction func scrollRight(sender: UIButton) {
        shiftTechniques(1)
    }
    
    @IBAction func swipedRight(sender: AnyObject) {
        shiftTechniques(1)
    }
    
    @IBAction func swipedLeft(sender: AnyObject) {
        shiftTechniques(-1)
    }
    
    @IBAction func chapterTouched(sender: UIGestureRecognizer) {
        guard let technique = technique else { return }
        let location = sender.locationInView(brushStack)
        for (index, view) in brushStack.arrangedSubviews.enumerate() {
            if view.frame.contains(location) {
                currentChapter = technique.orderedChapters()[index]
                if let chapter = currentChapter {
                    videoContainer.setTimeOffset(chapter.timeOffset)
                }
                return
            }
        }
    }
    
    @IBAction func addToPlaylistTouched(sender: UIButton) {
        guard let technique = technique where !technique.inPlaylist else { return }
        technique.inPlaylist = true
        CoreDataStack.shared.saveContext()
        updateButtons()
    }
    
}

extension TechniqueDetailViewController: AVPlayerViewDelegate {
    
    func player(player: AVPlayerView, didEnterChapterIndex index: Int?) {
        if let index = index, let selectedChapter = technique?.orderedChapters()[index]  {
            // if the chapter is equal to the current chapter that means we have already set it after the user interaction so no need to update it again.
            if currentChapter != selectedChapter {
                currentChapter = selectedChapter
            }
        } else {
            currentChapter = nil
        }
    }
    
    func playerDidFinishPlaying(player: AVPlayerView) {
        currentChapter = nil
        videoContainer.reset()
    }
    
    func playerDidRetrieveChapterData(dataArray: [[String : AnyObject]]) {
         dispatch_async(dispatch_get_main_queue(),{
            if let currentTechnique = self.technique {
                do {
                    try currentTechnique.updateWithJSONArray(dataArray)
                    CoreDataStack.shared.saveContext()
                } catch let error {
                    self.reportError("Error", message: "Could not load chapter data: \(error)")
                }
            }
            self.updateBasicData()
            self.updateChapters()
         })
    }
}

extension TechniqueDetailViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [dataStack, brushDetailsButton, addToPlaylistButton]
        for stackView in brushStack.arrangedSubviews as! [UIStackView] {
            views.append(stackView.arrangedSubviews[0])
            views.append(stackView.arrangedSubviews[1])
        }
        
        if !(otherVC is TechniqueBrowserViewController) { views.append(videoContainer) }
        return views
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case dataStack :
            return [TransitionAnimationItem(mode: .SlideRight, duration: 0.5)]
        case brushDetailsButton :
            return [TransitionAnimationItem(mode: .SlideRight, delay: 0.2, duration:  0.5)]
        case addToPlaylistButton :
            return [TransitionAnimationItem(mode: .SlideRight, delay: 0.1, duration: 0.5)]
        case videoContainer :
            return [TransitionAnimationItem(mode: .Fade)]
        default : break
        }
        
        let count = brushStack.arrangedSubviews.count
        let delay = 0.25 / Double(count) * Double(count - view.tag - 1) + 0.5
        if view is UILabel {
            return [TransitionAnimationItem(mode: .SlideLeft, delay: delay, duration: 0.25)]
        } else if view is UIImageView {
            return [TransitionAnimationItem(mode: .SlideBottom, delay: delay, duration: 0.25, quantity: view.frame.height)]
        }
        
        return nil
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if otherVC is TechniqueBrowserViewController { return [videoContainer] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return videoContainer
    }
    
}
