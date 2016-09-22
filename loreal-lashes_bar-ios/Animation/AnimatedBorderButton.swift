//
//  AnimatedBorderButton.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/** UIButton with an animated border. See `AnimatedBorderProtocol` for more details. */
class AnimatedBorderButton: UIButton, AnimatedBorderProtocol {

    internal var borderLayer = TintedBorderLayer()
    
    func fadeInSubviews() -> [UIView] {
        guard let titleLabel = titleLabel else { return [] }
        return [titleLabel]
    }
    
    private func adjustBorder() {
        borderLayer.fromTopLeft = true
        borderLayer.frame = bounds
        if borderLayer.superlayer == nil {
            self.layer.addSublayer(borderLayer)
        }
        borderLayer.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustBorder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustBorder()
    }
    
}