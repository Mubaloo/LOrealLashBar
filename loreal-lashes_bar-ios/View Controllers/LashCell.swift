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
    @IBOutlet weak var lashesImagesContainer: UIView!
    @IBOutlet weak var infoButton: UIButton!
    
    var imagesLoaded = 0
    
    var lash: Lash? {
        didSet {
            imagesLoaded += 1
            lengthTitleLabel.text = lash?.length
            nameLabel.text = lash?.name
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                let leftImage = UIImage(CGImage: (self.lash?.image.CGImage)!, scale: 1.0, orientation: .UpMirrored)
                let rightImage = self.lash?.image
                // create a minimal rendering of the image so it is loaded properly before we add it to the uiimageView
                UIGraphicsBeginImageContext(CGSizeMake(1,1));
                var context = UIGraphicsGetCurrentContext();
                CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), leftImage.CGImage);
                UIGraphicsEndImageContext();
                
                UIGraphicsBeginImageContext(CGSizeMake(1,1));
                context = UIGraphicsGetCurrentContext();
                CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), rightImage?.CGImage);
                UIGraphicsEndImageContext();
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.imagesLoaded == 1 {
                        self.leftLashImageView.image = leftImage
                        self.rightLashImageView.image = rightImage
                        self.imagesLoaded -= 1
                    }else{
                        self.imagesLoaded -= 1
                    }
                })
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLashImageView.image = nil
        rightLashImageView.image = nil
    }
}
