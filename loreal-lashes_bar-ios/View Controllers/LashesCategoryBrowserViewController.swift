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


//extension LashesBrowserViewController: TransitionAnimationDataSource {
//
//    private func viewEquivalent(otherVC: UIViewController) -> UIView? {
//        guard let detailVC = otherVC as? TechniqueDetailViewController,
//            technique = detailVC.technique,
//            itemNumber = techniques.indexOf(technique)
//            else { return nil }
//
//        let indexPath = NSIndexPath(forItem: itemNumber, inSection: 0)
//        guard let cell = techniqueCollection.cellForItemAtIndexPath(indexPath) as? TechniqueCell else { return nil }
//        return cell.videoPreview
//    }
//
//    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
//        return techniqueCollection.subviews.filter({ $0 is TechniqueCell || $0 is UICollectionReusableView })
//    }
//
//    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
//        guard let cell = view as? TechniqueCell,
//            indexPath = techniqueCollection.indexPathForCell(cell)
//            else { return [TransitionAnimationItem(mode: .Fade)] }
//
//        let count = techniqueCollection.visibleCells().count
//        let mode: TransitionAnimationMode = (indexPath.item % 2 == 1) ? .SlideLeft : .SlideRight
//        let delay = 0.5 / Double(count-1) * Double(indexPath.row)
//        return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
//    }
//
//    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
//        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
//        return nil
//    }
//
//    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
//        return viewEquivalent(otherVC)
//    }
//}
