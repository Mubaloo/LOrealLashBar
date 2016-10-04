//
//  TextUtilities.swift
//  loreal-brush_bar-ios
//
//  Created by Igor Nakonetsnoi on 27/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

extension UILabel {
    func sizeOfText(withMaxSize maxSize:CGSize) -> CGRect {
        if let txt = self.text {
            return txt.boundingRectWithSize(maxSize, options: [.UsesFontLeading, .UsesLineFragmentOrigin], attributes:[NSFontAttributeName: self.font], context: nil)
        } else {
            return CGRectZero
        }
    }
}