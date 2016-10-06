//
//  LashesBrowserViewController.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 22/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class LashesBrowserViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubtitleLabel: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    
    var selectedCategory: LashCategory? {
        didSet {
            lashes = selectedCategory?.orderedLashes()
        }
    }
    
    var lashes: [Lash]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateHeader()
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? LashDetailViewController, let button = sender as? UIButton, let lash = lashes?[button.tag] {
            detailVC.lash = lash
        }
    }
    
    @IBAction func unwindToLashesBrowser(sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
    
    func updateHeader () {
        headerImageView.image = selectedCategory?.image
        headerTitleLabel.text = selectedCategory?.name
        headerSubtitleLabel.text = selectedCategory?.detail
    }
}

extension LashesBrowserViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lashes = selectedCategory?.lashes else {
            return 0
        }
        return lashes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LashCell", forIndexPath: indexPath)
        
        guard let lashCell = cell as? LashCell, let lash = lashes?[indexPath.row] else {
            return cell
        }
        
        lashCell.infoButton.tag = indexPath.row
        lashCell.lash = lash
        cell.backgroundColor = UIColor.lightBG
        return cell
    }
}


extension LashesBrowserViewController: TransitionAnimationDataSource {
    private func viewEquivalent(otherVC: UIViewController) -> UIView? {
        if otherVC is LashesCategoryBrowserViewController { return headerContainer }
        
        guard let detailVC = otherVC as? LashDetailViewController,
            lash = detailVC.lash,
            itemNumber = lashes?.indexOf(lash)
            else { return nil }
        
        let indexPath = NSIndexPath(forItem: itemNumber, inSection: 0)
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? LashCell else { return nil }
        return cell.lashesImagesContainer
    }
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        var views: [UIView] = tableView.visibleCells
        views.append(headerContainer)
        return tableView.visibleCells
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let cell = view as? LashCell,
            indexPath = tableView.indexPathForCell(cell)
            else { return [TransitionAnimationItem(mode: .Fade)] }
        
        if otherVC is LashDetailViewController {
            return [TransitionAnimationItem(mode: .Fade)]
        }else{
            let count = tableView.visibleCells.count
            let mode: TransitionAnimationMode = .SlideTop
            let delay = 0.5 / Double(count-1) * Double(indexPath.row)
            return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
        }
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return viewEquivalent(otherVC)
    }
}
