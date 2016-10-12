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
    var manualTransitionLash: Lash?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Colour scheme setup
        view.backgroundColor = UIColor.lightBG
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHeader()
        tableView.reloadData()
        self.doManualTransitionIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        manualTransitionLash = nil
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? LashDetailViewController {
            if manualTransitionLash != nil {
                detailVC.lash = manualTransitionLash
            }else if let button = sender as? UIButton, let lash = lashes?[button.tag] {
                detailVC.lash = lash
            }
        }
    }
    
    @IBAction func unwindToLashesBrowser(_ sender: UIStoryboardSegue) {
        // Nothing to do; just an unwind target
    }
    
    func updateHeader () {
        headerImageView.image = selectedCategory?.image
        headerTitleLabel.text = selectedCategory?.name
        headerSubtitleLabel.text = selectedCategory?.detail
    }
    
    func doManualTransitionIfNeeded() {
        if manualTransitionLash != nil {
            self.performSegue(withIdentifier: "pushLashDetail", sender: nil)
        }
    }

}

extension LashesBrowserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lashes = selectedCategory?.lashes else {
            return 0
        }
        return lashes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LashCell", for: indexPath)
        
        guard let lashCell = cell as? LashCell, let lash = lashes?[(indexPath as NSIndexPath).row] else {
            return cell
        }
        
        lashCell.infoButton.tag = (indexPath as NSIndexPath).row
        lashCell.lash = lash
        cell.backgroundColor = UIColor.lightBG
        return cell
    }
}


extension LashesBrowserViewController: TransitionAnimationDataSource {
    fileprivate func viewEquivalent(_ otherVC: UIViewController) -> UIView? {
        if manualTransitionLash != nil {
            return nil
        }

        if otherVC is LashesCategoryBrowserViewController { return headerContainer }
        
        guard let detailVC = otherVC as? LashDetailViewController,
            let lash = detailVC.lash,
            let itemNumber = lashes?.index(of: lash)
            else { return nil }
        
        let indexPath = IndexPath(item: itemNumber, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? LashCell else { return nil }
        return cell.lashesImagesContainer
    }
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        if manualTransitionLash != nil {
            return nil
        }
        var views: [UIView] = tableView.visibleCells
        views.append(headerContainer)
        return tableView.visibleCells
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if manualTransitionLash != nil {
            return nil
        }
        guard let cell = view as? LashCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return [TransitionAnimationItem(mode: .fade)] }
        
        if otherVC is LashDetailViewController {
            return [TransitionAnimationItem(mode: .fade)]
        }else{
            let count = tableView.visibleCells.count
            let mode: TransitionAnimationMode = .slideTop
            let delay = 0.5 / Double(count-1) * Double((indexPath as NSIndexPath).row)
            return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
        }
    }
    
    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        if manualTransitionLash != nil {
            return nil
        }
        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
        return nil
    }
    
    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        if manualTransitionLash != nil {
            return nil
        }
        return viewEquivalent(otherVC)
    }
}
