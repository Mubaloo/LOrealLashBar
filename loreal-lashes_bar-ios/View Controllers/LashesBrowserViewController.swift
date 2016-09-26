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
    
    var selectedCategory: LashCategory?

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
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let detailVC = segue.destinationViewController as? BrushDetailViewController {
//            guard let centralIndex = centralIndex else { return }
//            detailVC.brush = brushes[centralIndex.section][centralIndex.item]
//        }
//    }
    
//    @IBAction func unwindToBrushBrowser(sender: UIStoryboardSegue) {
//        // Nothing to do; just an unwind target
//    }
    
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
        
        guard let lash = selectedCategory?.orderedLashes()[indexPath.row], let lashCell = cell as? LashCell else {
            return cell
        }
        
        lashCell.lash = lash
        cell.backgroundColor = UIColor.lightBG
        return cell
    }
}


extension LashesBrowserViewController: TransitionAnimationDataSource {
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
        if otherVC is LashesCategoryBrowserViewController { return [headerContainer] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return headerContainer
    }
}
