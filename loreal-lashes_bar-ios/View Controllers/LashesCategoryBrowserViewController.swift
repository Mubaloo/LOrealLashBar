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
    
    fileprivate var categories = [LashCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
        
        // load the data for the table view
        categories = LashCategory.orderedCategories()
        
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? LashesBrowserViewController, let cell = sender as? LashCategoryCell, let indexPath = tableView.indexPath(for: cell) {
            let category = categories[(indexPath as NSIndexPath).row]
            detailVC.selectedCategory = category
        }
    }
    
    @IBAction func unwindToLashesCategoryBrowser(_ sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
}

extension LashesCategoryBrowserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[(indexPath as NSIndexPath).row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LashCategoryCell", for: indexPath)
        
        if let categoryCell = cell as? LashCategoryCell {
            categoryCell.lashCategory = category
        }
        
        return cell
    }
}

extension LashesCategoryBrowserViewController: TransitionAnimationDataSource {

    fileprivate func viewEquivalent(_ otherVC: UIViewController) -> UIView? {
        guard let detailVC = otherVC as? LashesBrowserViewController,
            let category = detailVC.selectedCategory,
            let itemNumber = categories.index(of: category)
            else { return nil }

        let indexPath = IndexPath(item: itemNumber, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? LashCategoryCell else { return nil }
        return cell
    }

    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return tableView.visibleCells
    }

    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let cell = view as? LashCategoryCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return [TransitionAnimationItem(mode: .fade)] }

        if otherVC is LashesBrowserViewController {
            return [TransitionAnimationItem(mode: .fade)]
        }else{
            let count = tableView.visibleCells.count
            let mode: TransitionAnimationMode = .slideBottom
            let delay = 0.5 / Double(count-1) * Double((indexPath as NSIndexPath).row)
            return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5 - Double((indexPath as NSIndexPath).row) / 10)]
        }
    }

    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
        return nil
    }

    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        return viewEquivalent(otherVC)
    }
}
