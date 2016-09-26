//
//  LashCategoryCell.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 23/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class LashCategoryCell: UITableViewCell {
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var lashCategory: LashCategory? {
        didSet {
            mainImageView.image = lashCategory?.image
            mainTitleLabel.text = lashCategory?.name
            subtitleLabel.text = lashCategory?.detail
        }
    }
}

