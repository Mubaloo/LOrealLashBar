//
//  LashesCategoryBrowserViewController.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 23/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class LashesCategoryBrowserViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var categories = [LashCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
        
        // load the data for the table view
        categories = LashCategory.orderedCategories()
        
        tableView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? LashesBrowserViewController, let cell = sender as? LashCategoryCell, let indexPath = tableView.indexPathForCell(cell) {
            let category = categories[indexPath.row]
            detailVC.selectedCategory = category
        }
    }
    
    @IBAction func unwindToLashesCategoryBrowser(sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
}

extension LashesCategoryBrowserViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let category = categories[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LashCategoryCell", forIndexPath: indexPath)
        
        if let categoryCell = cell as? LashCategoryCell {
            categoryCell.lashCategory = category
        }
        
        return cell
    }
}

extension LashesCategoryBrowserViewController: TransitionAnimationDataSource {

    private func viewEquivalent(otherVC: UIViewController) -> UIView? {
        guard let detailVC = otherVC as? LashesBrowserViewController,
            category = detailVC.selectedCategory,
            itemNumber = categories.indexOf(category)
            else { return nil }

        let indexPath = NSIndexPath(forItem: itemNumber, inSection: 0)
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? LashCategoryCell else { return nil }
        return cell
    }

    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return tableView.visibleCells
    }

    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let cell = view as? LashCategoryCell,
            indexPath = tableView.indexPathForCell(cell)
            else { return [TransitionAnimationItem(mode: .Fade)] }

        if otherVC is LashesBrowserViewController {
            return [TransitionAnimationItem(mode: .Fade)]
        }else{
            let count = tableView.visibleCells.count
            let mode: TransitionAnimationMode = .SlideBottom
            let delay = 0.5 / Double(count-1) * Double(indexPath.row)
            return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5 - Double(indexPath.row) / 10)]
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
