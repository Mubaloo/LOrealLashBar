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
    
    fileprivate var techniques = [Technique]()
    
    var manualTransitionTechnique: Technique?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightBG
        techniques = Technique.orderedTechniques()
        
        let layout = InterspacedImageLayout()
        let dividerNib = UINib(nibName: "DividerView", bundle: nil)
        layout.register(dividerNib, forDecorationViewOfKind: "Separator")
        techniqueCollection.collectionViewLayout = layout
        techniqueCollection.reloadData()
        techniqueCollection.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doManualTransitionIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(TechniqueBrowserViewController.playVideos), name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        manualTransitionTechnique = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let techniqueVC = segue.destination as? TechniqueDetailViewController,
            let view = sender as? UIView {
            techniqueVC.technique = techniques[view.tag]
        }
    }
    
    @IBAction func unwindToTechniqueBrowser(_ segue: UIStoryboardSegue) {
        // No need to do anything here yet
    }

    func doManualTransitionIfNeeded() {
        if manualTransitionTechnique != nil {
            let view = UIView()
            view.tag = techniques.index(of: manualTransitionTechnique!)!
            self.performSegue(withIdentifier: "pushTechniqueDetail", sender: view)
        }
    }
    
    func playVideos() {
        for cell in techniqueCollection.visibleCells {
            if let techCell = cell as? TechniqueCell {
                techCell.startPlayer()
            }
        }
    }
}

extension TechniqueBrowserViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return min(techniques.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return techniques.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellID = ((indexPath as NSIndexPath).item % 2 == 0) ? "TechniqueCellA" : "TechniqueCellB"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        if let techniqueCell = cell as? TechniqueCell {
            techniqueCell.technique = techniques[(indexPath as NSIndexPath).row]
            techniqueCell.watchButton.tag = (indexPath as NSIndexPath).row
            techniqueCell.tag = (indexPath as NSIndexPath).row
        }
        return cell
    }
    
}

extension TechniqueBrowserViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVideos()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if decelerate == false {
            playVideos()
        }
    }
}

extension TechniqueBrowserViewController: TransitionAnimationDataSource {
    
    fileprivate func viewEquivalent(_ otherVC: UIViewController) -> UIView? {
        if manualTransitionTechnique != nil {
            return nil
        }
        guard let detailVC = otherVC as? TechniqueDetailViewController,
            let technique = detailVC.technique,
            let itemNumber = techniques.index(of: technique)
            else { return nil }
        
        let indexPath = IndexPath(item: itemNumber, section: 0)
        guard let cell = techniqueCollection.cellForItem(at: indexPath) as? TechniqueCell else { return nil }
        return cell.videoPreview
    }
    
    func transitionableViews(_ direction: TransitionAnimationDirection, otherVC: UIViewController) -> [UIView]? {
        if manualTransitionTechnique != nil {
            return nil
        }
        return techniqueCollection.subviews.filter({ $0 is TechniqueCell || $0 is UICollectionReusableView })
    }
    
    func transitionAnimationItemsForView(_ view: UIView, direction: TransitionAnimationDirection, otherVC: UIViewController) -> [TransitionAnimationItem]? {
        if manualTransitionTechnique != nil {
            return nil
        }
        guard let cell = view as? TechniqueCell,
            let indexPath = techniqueCollection.indexPath(for: cell)
            else { return [TransitionAnimationItem(mode: .fade)] }
        
        let count = techniqueCollection.visibleCells.count
        let mode: TransitionAnimationMode = ((indexPath as NSIndexPath).item % 2 == 1) ? .slideLeft : .slideRight
        let delay = 0.5 / Double(count-1) * Double((indexPath as NSIndexPath).row)
        return [TransitionAnimationItem(mode: mode, delay: delay, duration: 0.5)]
    }
    
    func viewsWithEquivalents(_ otherVC: UIViewController) -> [UIView]? {
        if manualTransitionTechnique != nil {
            return nil
        }
        if let equivalent = viewEquivalent(otherVC) { return [equivalent] }
        return nil
    }
    
    func equivalentViewForView(_ view: UIView, otherVC: UIViewController) -> UIView? {
        if manualTransitionTechnique != nil {
            return nil
        }
        return viewEquivalent(otherVC)
    }
    
}
