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
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var emailContainer: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var interfaceBottom: NSLayoutConstraint!
    
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var tickMarkBackground: UIView!
    @IBOutlet weak var tickMarkImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentTimer: Timer?
    
    var playlistItems: [PlaylistItem] = {
        var allItems = Lash.playlist().map({ $0 as PlaylistItem })
        let allTechniques = Technique.playlist().map({ $0 as PlaylistItem })
        allItems.append(contentsOf: allTechniques)
        for item in allItems { item.precache() }
        return allItems
    }()
    
    lazy var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        titleBar.backgroundColor = UIColor.lightBG
        tickMarkBackground.layer.cornerRadius = 3
        playlistCollection.collectionViewLayout = PagedGridLayout()
        playlistCollection.reloadData()
        sendButton.isEnabled = false
        emailField.isUserInteractionEnabled = playlistItems.count > 0
        emailField.enablesReturnKeyAutomatically = playlistItems.count > 0;
        
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self, selector: #selector(PlaylistViewController.updateKeyboard(_:)),
                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        emailField.addTarget(self, action: #selector(PlaylistViewController.textFieldDidChange), for: .editingChanged)
        
        // Timer is added because of a bug with AVPlayer and/or AVPlayerLayer. I found two issues - 1. AVPlayer.play() is called but the player does not actually start playing 2. AVPlayer supposedly starts playing (rate is 1) but it doesn't actually appear until the imposter image is hidden.
        // Timer solves issue 1, issue 2 is solved by hiding the imposter image in the cell (which is causing the cell image flashing issue).
        // Not sure what the exact underlying cause is but possibly an AVPlayer bug that has been filed before https://github.com/lionheart/openradar-mirror/issues/7052 https://openradar.appspot.com/24025392 and https://openradar.appspot.com/28553945
        currentTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PlaylistViewController.playStoppedVideos), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentTimer?.invalidate()
        currentTimer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func emailIsValid() -> Bool {
        guard let email = emailField.text , email.characters.count > 0 else { return false }
        let splitAt = email.components(separatedBy: "@")
        if splitAt.count != 2 { return false }
        return splitAt[1].components(separatedBy: ".").count > 1
    }
    
    // TODO: test full implementation when web service is in place on the back end.
    @IBAction func unwindToPlaylistVC(_ segue: UIStoryboardSegue) {
        // No need to do anything here yet
    }
    
    @IBAction func sendButtonTouched (_ sender: UIButton) {
        if emailIsValid(), let emailAddress = emailField.text {
            let videoItems = playlistItems.map { ( item: PlaylistItem) -> [String:String] in
                guard let url = item.remoteMediaURL, let id = item.remoteVideoId, let type = item.remoteVideoType else {
                    return ["":""]
                }
                return ["Landing_URL" : url, "Video_Id" : id, "Video_Type" : type]
            }
            let request = EntryEventRequest(
                emailAddress: emailAddress,
                videoItems: videoItems,
                emailStatus: !self.tickMarkImageView.isHidden,
                sendDate: self.formatter.string(from: NSDate() as Date)
            )

            self.emailContainer.isHidden = true
            self.statusContainer.isHidden = false
            _ = request.executeInSharedSession {
                switch $0 {
                case .success(_) :
                    self.statusLabel.text = "Sent to \(emailAddress)!"
                    self.statusImageView.image = UIImage(named: "loaded-lips")
                    guard let app = UIApplication.shared as? TimeOutApplication else { return }
                    app.beginShortTimeout()
                case .successNoData :
                    self.statusLabel.text = "Sent to \(emailAddress)!"
                    self.statusImageView.image = UIImage(named: "loaded-lips")
                    guard let app = UIApplication.shared as? TimeOutApplication else { return }
                    app.beginShortTimeout()
                case .failure(_) :
                    self.statusContainer.isHidden = true
                    self.emailContainer.isHidden = false
                }
            }
        }
        
        else {
            let alert = UIAlertController(title: title, message: "Please enter a valid email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            emailField.becomeFirstResponder()
        }
    }
    
    @IBAction func closeButtonTouched(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tickContainerTouched(_ sender: AnyObject) {
        if tickMarkImageView.isHidden == true {
            tickMarkImageView.isHidden = false
        }else{
            tickMarkImageView.isHidden = true
        }
    }
    
    func updateKeyboard(_ notif: Notification) {
        guard let value = (notif as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let frame = value.cgRectValue
        if frame.maxX < view.bounds.maxX { return }
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.interfaceBottom.constant = strongSelf.view.bounds.maxY - frame.minY
            strongSelf.view.layoutIfNeeded()
        })
    }
    
    func updatePageNumber() {
        if let layout = playlistCollection.collectionViewLayout as? PagedGridLayout, let cell = playlistCollection.visibleCells.first   {
            let page = layout.pageForIndexPath(playlistCollection.indexPath(for: cell)!)
            pageControl.currentPage = page
        }
    }
    
    func updateSendButton() {
        if playlistItems.count > 0 && (emailField.text?.characters.count)! > 0 {
            sendButton.isEnabled = true
        }else{
            sendButton.isEnabled = false
        }
    }
    
    func playVideos() {
        for cell in playlistCollection.visibleCells {
            if let videoCell = cell as? MyPlaylistCell {
                DispatchQueue.main.async {
                    videoCell.startPlayer()
                }
            }
        }
    }
    
    func playStoppedVideos() {
        for cell in playlistCollection.visibleCells {
            if let videoCell = cell as? MyPlaylistCell {
                if videoCell.player?.rate == 0 {
                    videoCell.startPlayer()
                }
            }
        }
    }
}

extension PlaylistViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidChange() {
        updateSendButton()
    }
}

extension PlaylistViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let layout = playlistCollection.collectionViewLayout as? PagedGridLayout  {
            pageControl.numberOfPages = Int(ceil(Float(playlistItems.count) / Float(layout.rowsPerPage) / Float(layout.columnsPerPage)))
        }
        let roundUp = Int(ceil(Float(playlistItems.count) / 4)) * 4
        return max(roundUp, 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellID = (indexPath as NSIndexPath).item >= playlistItems.count ? "EmptyVideoCell" : "VideoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        if let videoCell = cell as? MyPlaylistCell {
            videoCell.item = playlistItems[(indexPath as NSIndexPath).item]
            videoCell.delegate = self
        }
        return cell
    }
    
}

extension PlaylistViewController: UICollectionViewDelegate {
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if decelerate == false {
            playVideos()
        }
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageNumber()
        playVideos()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if (indexPath as NSIndexPath).item >= playlistItems.count {
             presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            presentingViewController?.dismiss(animated: true, completion: nil)
            let object = playlistItems[indexPath.item]
            let notification = Notification(name: Notification.Name(rawValue: TitleBarViewController.NavigationTriggeredNotification), object: nil, userInfo: ["object":object])
            NotificationCenter.default.post(notification)
        }
    }
    
}

extension PlaylistViewController: TransitionAnimationDataSource {
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = [titleBar,  myPlaylistLabel, emailContainer, closeButton]
        views.append(contentsOf: playlistCollection.visibleCells as [UIView])
        return views
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        switch view {
        case titleBar :
            return [TransitionAnimationItem(mode: .slideTop, duration: 0.5, quantity: view.frame.height)]
        case myPlaylistLabel :
            return [TransitionAnimationItem(mode: .slideLeft, delay: 0.5, duration: 0.5)]
        case emailContainer :
            return [TransitionAnimationItem(mode: .slideBottom, duration: 0.5, quantity: view.frame.height)]
        case closeButton :
            return [TransitionAnimationItem(mode: .slideRight, delay: 0.5, duration: 0.5, quantity: 100)]
        default : break
        }
        
        guard let cell = view as? UICollectionViewCell,
            let indexPath = playlistCollection.indexPath(for: cell)
            else { return nil }
        
        let first = Int(floor(playlistCollection.contentOffset.x / playlistCollection.frame.width)) * 4
        let mode: TransitionAnimationMode = ((indexPath as NSIndexPath).row % 2 == 0) ? .slideLeft : .slideRight
        let delay = 0.5 / Double(playlistCollection.visibleCells.count) * Double((indexPath as NSIndexPath).row - first)
        return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
    }
    
}

extension PlaylistViewController: PlaylistCellDelegate {
    
    func cellWantsToBeRemoved(_ cell: MyPlaylistCell) {
        guard let indexPath = playlistCollection.indexPath(for: cell) else { return }
        
        let itemsBefore = collectionView(playlistCollection, numberOfItemsInSection: 0)
        var item = playlistItems[(indexPath as NSIndexPath).item]
        item.isInPlaylist = false
        CoreDataStack.shared.saveContext()
        playlistItems.remove(at: (indexPath as NSIndexPath).item)
        
        updateSendButton()
        emailField.isUserInteractionEnabled = playlistItems.count > 0
        emailField.enablesReturnKeyAutomatically = playlistItems.count > 0;
        
        let itemsAfter = collectionView(playlistCollection, numberOfItemsInSection: 0)
        
        if itemsBefore != itemsAfter && itemsAfter != 0 {
            let first = Int(floor(Float(itemsBefore - 1) / 4)) * 4
            let range = first ..< first + 4
            let indices = range.map({ IndexPath(item: $0, section: 0) })
            playlistCollection.deleteItems(at: indices)
        }
        
        if (indexPath as NSIndexPath).item >= itemsAfter { return }
        let last = Int(floor(Float((indexPath as NSIndexPath).item) / 4) + 1) * 4
        let range = (indexPath as NSIndexPath).item ..< last
        let indices = range.map({ IndexPath(item: $0, section: 0) })
        weak var weakSelf = self
        playlistCollection.performBatchUpdates({ 
            weakSelf?.playlistCollection.reloadItems(at: indices)
            }) { (_) in
               weakSelf?.playVideos()
        }
    }
}
