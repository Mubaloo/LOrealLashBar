//
//  TitleBarViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit
import CoreData

enum BrowserType: String {
    case Lashes = "LASHES"
    case Technique = "TECHNIQUES"
}

/**
 This view controller acts as the basic parent of the user interface, once the attract screen
 has been dismissed. It encapsulates a tab bar controller for switching back and forth between
 lashes and techniques, as well as the bar at the top of the screen containing a button to
 perform this action, plus a button to present the user's current playlist.
 */

class TitleBarViewController: BaseViewController {

    @IBOutlet var titleBar: UIView!
    @IBOutlet var browserButton: UIButton!
    @IBOutlet var playlistButton: UIButton!
    @IBOutlet var containerView: UIView!
    
    private var childTabBarController: UITabBarController?
    private var browserType = BrowserType.Lashes
    
    /** Fetch controller used solely for handling the number tag in the Playlist button. This one fetches lashes. */
    private var lashFetch: NSFetchedResultsController = {
        let context = CoreDataStack.shared.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Lash")
        fetchRequest.predicate = NSPredicate(format: "inPlaylist == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    /** Fetch controller used solely for handling the number tag in the Playlist button. This one fetches techniques. */
    private var techniqueFetch: NSFetchedResultsController = {
        let context = CoreDataStack.shared.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Technique")
        fetchRequest.predicate = NSPredicate(format: "inPlaylist == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up colour scheme.
        view.backgroundColor = UIColor.lightBG
        containerView.backgroundColor = UIColor.lightBG
        titleBar.backgroundColor = UIColor.lightBG
        browserButton.backgroundColor = UIColor.hotPink
        playlistButton.backgroundColor = UIColor.hotPink
        setBrowserType(browserType, animated: false)
        
        // Prepare the two fetch controllers.
        lashFetch.delegate = self
        techniqueFetch.delegate = self
        try! lashFetch.performFetch()
        try! techniqueFetch.performFetch()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tbc = segue.destinationViewController as? UITabBarController {
            childTabBarController = tbc
            tbc.tabBar.hidden = true
            tbc.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
            for navigator in tbc.viewControllers as! [UINavigationController] {
                navigator.delegate = UIApplication.sharedApplication().delegate as? UINavigationControllerDelegate
            }
        }
    }
    
    func setBrowserType(newType: BrowserType, animated: Bool = false) {
        browserType = newType
        guard let childTabBarController = childTabBarController,
            viewControllers = childTabBarController.viewControllers
            else { return }
        
        switch browserType {
        case .Lashes :
            childTabBarController.selectedViewController = viewControllers[0]
            browserButton.setTitle(BrowserType.Technique.rawValue, forState: .Normal)
        case .Technique :
            childTabBarController.selectedViewController = viewControllers[1]
            browserButton.setTitle(BrowserType.Lashes.rawValue, forState: .Normal)
        }
    }
    
    @IBAction func browserButtonTouched(sender: UIButton) {
        switch browserType {
        case .Lashes : self.setBrowserType(.Technique, animated: true)
        case .Technique : self.setBrowserType(.Lashes, animated: true)
        }
    }
    
    @IBAction func unwindToTitleBar(sender: UIStoryboardSegue) {
        // Don't do anything yet
    }
    
}

extension TitleBarViewController: TransitionAnimationDataSource {
    
    // Transition animation views must be conjoined with those from the currently displayed view controller.
    // This function simply returns that view controller if it conforms to the appropriate protocol. If it
    // does not, the results of calling those methods would be nil anyway so we can return nil here and save
    // the bother of checking separately.
    private func currentlyDisplayedDataSource() -> TransitionAnimationDataSource? {
        guard childViewControllers.count > 0,
            let tabBar = childViewControllers[0] as? UITabBarController,
            navigator = tabBar.selectedViewController as? UINavigationController,
            viewController = navigator.topViewController
            else { return nil }
        
        return viewController as? TransitionAnimationDataSource
    }
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views = [UIView]()
        views.append(titleBar)
        
        // Concatinate with views from the currently displayed child.
        if let child = currentlyDisplayedDataSource() {
            if let additional = child.transitionableViews(direction, otherVC: otherVC) {
                views.appendContentsOf(additional)
            } else if let vc = child as? UIViewController {
                views.append(vc.view)
            }
        }
        
        return views
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if view == titleBar {
            switch direction {
            case .Appear : return [TransitionAnimationItem(mode: .Fade, duration: 0.3)]
            case .Disappear : return [TransitionAnimationItem(mode: .Fade, duration: 1)]
            }
        }
        
        // Retrieve data relevant to the currently displayed child.
        guard let child = currentlyDisplayedDataSource() else { return nil }
        if let animations = child.transitionAnimationItemsForView(view, direction: direction, otherVC: otherVC) {
            return animations
        }
        
        if let vc = child as? UIViewController where vc.view == view {
            return [TransitionAnimationItem(mode: .Fade)]
        }
        
        return nil
    }
    
}

extension TitleBarViewController: NSFetchedResultsControllerDelegate {
    
    // Updates the number in the My Playlists button when something is added or removed.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let lashCount = lashFetch.fetchedObjects?.count ?? 0
        let techniqueCount = techniqueFetch.fetchedObjects?.count ?? 0
        let total = lashCount + techniqueCount
        
        if total == 0 {
            playlistButton.setTitle("MY PLAYLIST", forState: .Normal)
        } else {
            playlistButton.setTitle("MY PLAYLIST (\(total))", forState: .Normal)
        }
    }
    
}
