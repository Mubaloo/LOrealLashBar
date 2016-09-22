//
//  TechniqueBrowserViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueBrowserViewController: BaseViewController {
    
    @IBOutlet var techniqueCollection: UICollectionView!
    
    private var techniques = [Technique]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        techniques = Technique.orderedTechniques()
        
        let layout = InterspacedImageLayout()
        let dividerNib = UINib(nibName: "DividerView", bundle: nil)
        layout.registerNib(dividerNib, forDecorationViewOfKind: "Separator")
        techniqueCollection.collectionViewLayout = layout
        techniqueCollection.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let techniqueVC = segue.destinationViewController as? TechniqueDetailViewController,
            view = sender as? UIView {
            techniqueVC.technique = techniques[view.tag]
        }
    }
    
    @IBAction func unwindToTechniqueBrowser(segue: UIStoryboardSegue) {
        // No need to do anything here yet
    }

}

extension TechniqueBrowserViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return min(techniques.count, 1)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return techniques.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellID = (indexPath.item % 2 == 0) ? "TechniqueCellA" : "TechniqueCellB"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath)
        if let techniqueCell = cell as? TechniqueCell {
            techniqueCell.technique = techniques[indexPath.row]
            techniqueCell.watchButton.tag = indexPath.row
            techniqueCell.tag = indexPath.row
        }
        return cell
    }
    
}

extension TechniqueBrowserViewController: TransitionAnimationDataSource {
    
    private func viewEquivalent(otherVC: UIViewController) -> UIView? {
        guard let detailVC = otherVC as? TechniqueDetailViewController,
            technique = detailVC.technique,
            itemNumber = techniques.indexOf(technique)
            else { return nil }
        
        let indexPath = NSIndexPath(forItem: itemNumber, inSection: 0)
        guard let cell = techniqueCollection.cellForItemAtIndexPath(indexPath) as? TechniqueCell else { return nil }
        return cell.videoPreview
    }
    
    func transitionableViews(direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        return techniqueCollection.subviews.filter({ $0 is TechniqueCell || $0 is UICollectionReusableView })
    }
    
    func transitionAnimationItemsForView(view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        guard let cell = view as? TechniqueCell,
            indexPath = techniqueCollection.indexPathForCell(cell)
            else { return [TransitionAnimationItem(mode: .Fade)] }
        
        let count = techniqueCollection.visibleCells().count
        let mode: TransitionAnimationMode = (indexPath.item % 2 == 1) ? .SlideLeft : .SlideRight
        let delay = 0.5 / Double(count-1) * Double(indexPath.row)
        return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
    }
    
    func viewsWithEquivalents(otherVC: UIViewController) -> [UIView]? {
        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
        return nil
    }
    
    func equivalentViewForView(view: UIView, otherVC: UIViewController) -> UIView? {
        return viewEquivalent(otherVC)
    }
    
}