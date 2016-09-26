//
//  LashCell.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 26/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class LashCell: UITableViewCell {
    @IBOutlet weak var lengthTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftLashImageView: UIImageView!
    @IBOutlet weak var rightLashImageView: UIImageView!
    
    var lash: Lash? {
        didSet {
            lengthTitleLabel.text = lash?.length
            nameLabel.text = lash?.name
        }
    }
}
