//
//  TechniqueDetailsView.swift
//  loreal-brush_bar-ios
//
//  Created by Igor Nakonetsnoi on 27/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class TechniqueDetailsCell: UICollectionViewCell {
    @IBOutlet var techniqueNameLabel: UILabel!
    @IBOutlet var techniqueDetailLabel: UILabel!
    @IBOutlet var brushNameLabel: UILabel!
    
    @IBOutlet var addToPlaylistButton: UIButton!
    
    var technique: Technique? {
        didSet {
            guard let technique = technique else { return }
            techniqueNameLabel.text = technique.level
            techniqueDetailLabel.text = technique.detail
            brushNameLabel.text = technique.name
        }
    }
}