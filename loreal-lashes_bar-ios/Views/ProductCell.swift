//
//  ProductCell.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 02/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var product: Product? {
        didSet {
            imageView.image = product?.image
            nameLabel.text = product?.name
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.alpha = 0
    }
    
    override var selected: Bool {
        didSet {
            let completion: (Bool)->() = { finished in
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue(), {
                    UIView.animateWithDuration(
                        0.25,
                        animations: { self.nameLabel.alpha = 0 },
                        completion: nil
                    )
                })
            }
            
            UIView.animateWithDuration(
                0.25,
                animations: { self.nameLabel.alpha = self.selected ? 1 : 0 },
                completion: completion
            )
        }
    }
}