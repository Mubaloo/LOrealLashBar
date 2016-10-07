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
    
    override var isSelected: Bool {
        didSet {
            let completion: (Bool)->() = { finished in
                let time = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    UIView.animate(
                        withDuration: 0.25,
                        animations: { self.nameLabel.alpha = 0 },
                        completion: nil
                    )
                })
            }
            
            UIView.animate(
                withDuration: 0.25,
                animations: { self.nameLabel.alpha = self.isSelected ? 1 : 0 },
                completion: completion
            )
        }
    }
}
