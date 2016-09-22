//
//  PlaylistViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class PlaylistViewController: BaseViewController {

    @IBOutlet var titleBar: UIView!
    @IBOutlet var myPlaylistLabel: UILabel!
    @IBOutlet var playlistCollection: UICollectionView!
    @IBOutlet var closeButton: UIButton!
    
    @IBOutlet var unsentStack: UIStackView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var emailContainer: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var interfaceBottom: NSLayoutConstraint!
    
    var playlistItems: [PlaylistItem] = {
        var allItems = Lash.playlist().map({ $0 as PlaylistItem })
        let allTechniques = Technique.playlist().map({ $0 as PlaylistItem })
        allItems.appendContentsOf(allTechniques)
        for item in allItems { item.precache() }
        return allItems
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        titleBar.backgroundColor = UIColor.lightBG
        playlistCollection.collectionViewLayout = PagedGridLayout()
        playlistCollection.reloadData()
        sendButton.enabled = playlistItems.count > 0
        
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(PlaylistViewController.updateKeyboard(_:)),
                               name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func emailIsValid() -> Bool {
        guard let email = emailField.text where email.characters.count > 0 else { return false }
        let splitAt = email.componentsSeparatedByString("@")
        if splitAt.count != 2 { return false }
        return splitAt[1].componentsSeparatedByString(".").count > 1
    }
    
    // TODO: test full implementation when web service is in place on the back end.
    
    @IBAction func sendButtonTouched (sender: UIButton) {
        if emailIsValid(), let emailAddress = emailField.text {
            let urls = playlistItems.flatMap({ $0.remoteMediaURL?.path })
            let request = EntryEventRequest(
                emailAddress: emailAddress,
                videoURLs: urls
            )
            
            request.executeInSharedSession {
                switch $0 {
                case .Success(let response) :
                    print("Email sent to \(emailAddress)")
                    print(response)
                case .SuccessNoData :
                    print("Email sent to \(emailAddress) (no data in response)")
                case .Failure(let error) :
                    print("Error sending email: \(error)")
                }
            }
        }
        
        else { emailField.becomeFirstResponder() }
    }
    
    @IBAction func closeButtonTouched(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateKeyboard(notif: NSNotification) {
        guard let value = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let frame = value.CGRectValue()
        if frame.maxX < view.bounds.maxX { return }
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.interfaceBottom.constant = strongSelf.view.bounds.maxY - frame.minY
            strongSelf.view.layoutIfNeeded()
        })
    }
    
}

extension PlaylistViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}

extension PlaylistViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let roundUp = Int(ceil(Float(playlistItems.count) / 4)) * 4
        return max(roundUp, 4)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellID = indexPath.item >= playlistItems.count ? "EmptyVideoCell" : "VideoCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath)
        if let videoCell = cell as? MyPlaylistCell {
            videoCell.item = playlistItems[indexPath.item]
            videoCell.delegate = self
        }
        return cell
    }
    
}

extension PlaylistViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        for cell in playlistCollection.visibleCells() {
            if let videoCell = cell as? MyPlaylistCell {
                videoCell.playerView.pause()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        for cell in playlistCollection.visibleCells() {
            if let videoCell = cell as? MyPlaylistCell {
                videoCell.playerView.play()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        if indexPath.item >= playlistItems.count {
             presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

extension PlaylistViewController: TransitionAnimationDataSource {
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [titleBar,  myPlaylistLabel, emailContainer, closeButton]
        views.appendContentsOf(playlistCollection.visibleCells() as [UIView])
        return views
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case titleBar :
            return [TransitionAnimationItem(mode: .SlideTop, duration: 0.5, quantity: view.frame.height)]
        case myPlaylistLabel :
            return [TransitionAnimationItem(mode: .SlideLeft, delay: 0.5, duration: 0.5)]
        case emailContainer :
            return [TransitionAnimationItem(mode: .SlideBottom, duration: 0.5, quantity: view.frame.height)]
        case closeButton :
            return [TransitionAnimationItem(mode: .SlideRight, delay: 0.5, duration: 0.5, quantity: 100)]
        default : break
        }
        
        guard let cell = view as? UICollectionViewCell,
            indexPath = playlistCollection.indexPathForCell(cell)
            else { return nil }
        
        let first = Int(floor(playlistCollection.contentOffset.x / playlistCollection.frame.width)) * 4
        let mode: TransitionAnimationMode = (indexPath.row % 2 == 0) ? .SlideLeft : .SlideRight
        let delay = 0.5 / Double(playlistCollection.visibleCells().count) * Double(indexPath.row - first)
        return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
    }
    
}

extension PlaylistViewController: PlaylistCellDelegate {
    
    func cellWantsToBeRemoved(cell: MyPlaylistCell) {
        guard let indexPath = playlistCollection.indexPathForCell(cell) else { return }
        
        let itemsBefore = collectionView(playlistCollection, numberOfItemsInSection: 0)
        var item = playlistItems[indexPath.item]
        item.isInPlaylist = false
        CoreDataStack.shared.saveContext()
        playlistItems.removeAtIndex(indexPath.item)
        let itemsAfter = collectionView(playlistCollection, numberOfItemsInSection: 0)
        
        if itemsBefore != itemsAfter && itemsAfter != 0 {
            let first = Int(floor(Float(itemsBefore - 1) / 4)) * 4
            let range = first ..< first + 4
            let indices = range.map({ NSIndexPath(forItem: $0, inSection: 0) })
            playlistCollection.deleteItemsAtIndexPaths(indices)
        }
        
        if indexPath.item >= itemsAfter { return }
        let last = Int(floor(Float(indexPath.item) / 4) + 1) * 4
        let range = indexPath.item ..< last
        let indices = range.map({ NSIndexPath(forItem: $0, inSection: 0) })
        playlistCollection.reloadItemsAtIndexPaths(indices)
    }
    
}
