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
    
    private var categories = [LashCategory]()

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Colour scheme setup
//        view.backgroundColor = UIColor.lightBG
//        brushInfoStack.backgroundColor = UIColor.lightBG
//        brushNumberLabel.textColor = UIColor.hotPink
//        brushCategoryLabel.textColor = UIColor.hotPink
//        
//        // Prepare a list of all the categories and brushes.
//        let catList = BrushCategory.orderedCategories()
//        let brushList = catList.map({ $0.orderedBrushes() })
//        catCount = catList.count
//        
//        // Treble both so that they can be rotated through
//        let trebleCats = Array([catList, catList, catList].flatten())
//        categories = trebleCats.map({ $0.name })
//        brushes = Array([brushList, brushList, brushList].flatten())
//        
//        // Custom layouts for both collection views
//        let brushLayout = HighlightCarouselLayout()
//        brushCollection.collectionViewLayout = brushLayout
//        brushCollection.decelerationRate = UIScrollViewDecelerationRateFast
//        
//        let categoryLayout = HighlightCarouselLayout()
//        categoryCollection.collectionViewLayout = categoryLayout
//        
//        // Set the data for the initial brush
//        setCentralIndex(NSIndexPath(forItem: 0, inSection: catCount), animated: false)
//        
//        // Set text with kerning
//        let attribs: [String: AnyObject] = [
//            NSFontAttributeName : viewDetailsButton.titleLabel!.font,
//            NSForegroundColorAttributeName : UIColor.hotPink,
//            NSKernAttributeName : NSNumber(int: 2)
//        ]
//        
//        let title = NSAttributedString(string: "VIEW DETAILS", attributes: attribs)
//        viewDetailsButton.setAttributedTitle(title, forState: .Normal)
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // We only want to do this once
//        if hasAppeared { return }
//        brushCollection.scrollToItemAtIndexPath(centralIndex!, atScrollPosition: .CenteredHorizontally, animated: false)
//        categoryCollection.scrollToItemAtIndexPath(centralIndex!, atScrollPosition: .CenteredHorizontally, animated: false)
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        hasAppeared = true
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let detailVC = segue.destinationViewController as? BrushDetailViewController {
//            guard let centralIndex = centralIndex else { return }
//            detailVC.brush = brushes[centralIndex.section][centralIndex.item]
//        }
//    }
//    
//    @IBAction func unwindToBrushBrowser(sender: UIStoryboardSegue) {
//        // Nothing to do; just an unwind target
//    }
    
}

//extension BrushBrowserViewController: UICollectionViewDataSource {
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        if collectionView == categoryCollection { return categories.count }
//        return brushes.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == categoryCollection { return 1 }
//        return brushes[section].count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let isCategory = collectionView == categoryCollection
//        
//        let cell = isCategory ?
//            collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) :
//            collectionView.dequeueReusableCellWithReuseIdentifier("BrushCell", forIndexPath: indexPath)
//        
//        if let brushCell = cell as? BrushCarouselCell {
//            brushCell.brush = brushes[indexPath.section][indexPath.row]
//        }
//        
//        if let catCell = cell as? CategoryCarouselCell {
//            catCell.text = categories[indexPath.section]
//        }
//        
//        return cell
//    }
//    
//}
//
//extension LashesBrowserViewController: UITableViewDataSource {
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categories.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        <#code#>
//    }
//}
//
//
//extension BrushBrowserViewController: TransitionAnimationDataSource {
//    
//    func transitionableViews(direction: TransitionAnimationDirection,  otherVC: UIViewController) -> [UIView]? {
//        if otherVC is UINavigationController { return nil }
//        return [viewDetailsButton, headlineStack, brushDetailLabel, brushCollection, brushNameLabel, categoryCollection, brushStroke]
//    }
//    
//    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
//        switch view {
//        case viewDetailsButton :
//            switch direction {
//            case .Appear : return [TransitionAnimationItem(mode: .Native, duration: 0.35, delay: 0.35)]
//            case .Disappear : return [TransitionAnimationItem(mode: .SlideRight, duration: 0.67, delay: 0.33)]
//            }
//            
//        case brushCollection :
//            return [TransitionAnimationItem(mode: .Fade, duration: 0.67, delay: 0.33)]
//            
//        case headlineStack, brushDetailLabel :
//            switch direction {
//            case .Appear : return [TransitionAnimationItem(mode: .Fade, duration: 0.67, delay: 0.33)]
//            case .Disappear : return [TransitionAnimationItem(mode: .SlideLeft, duration: 0.67, delay: 0.33)]
//            }
//            
//        case brushNameLabel :
//            switch  direction {
//            case .Appear :
//                let frame = self.view.convertRect(view.frame, fromView: view.superview)
//                return [TransitionAnimationItem(mode: .SlideTop, duration: 0.67, delay: 0.33, quantity: frame.maxY)]
//            case .Disappear :
//                return [TransitionAnimationItem(mode: .SlideRight, duration: 0.5, delay: 0.5)]
//            }
//            
//        case brushStroke :
//            let alpha: CGFloat = otherVC is BrushDetailViewController ? 0.3 : 0
//            return [TransitionAnimationItem(mode: .Fade, quantity: alpha)]
//            
//        case categoryCollection :
//            return [TransitionAnimationItem(mode: .SlideBottom, duration: 0.67, delay: 0.33, quantity: brushStroke.frame.height)]
//            
//        default : return nil
//        }
//    }
//    
//}
