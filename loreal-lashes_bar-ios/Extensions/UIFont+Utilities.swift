//
//  UIFont+Utilities.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 18/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

extension UIFont {
    
    /**
     Handy method for printing the names of all installed fonts. Useful when working
     with non-standard fonts.
    */
    class func logAllFonts() {
        for family in UIFont.familyNames() {
            print("----------\(family)")
            print(UIFont.fontNamesForFamilyName(family).joinWithSeparator(" / "))
        }
    }
    
}