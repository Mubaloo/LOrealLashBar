//
//  Mathematics.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 19/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation

struct FloatRange {
    let start: Float
    let end: Float
    
    func contains(number: Float) -> Bool {
        return start <= number && end >= number
    }
    
    func constrain(number: Float) -> Float {
        if number <= start { return start }
        if number >= end { return end }
        return number
    }
}

extension Float {
    
    /**
     Returns the result of converting the receiver from one potential range to another.
     This is accomplished by working out the point at which the receiver sits in `fromRange`,
     from 0% (start) to 100% (end), and applying that percentage to the `toRange` in the
     same fashion.
     */
    func normalise(fromRange: FloatRange, toRange: FloatRange) -> Float {
        if self <= fromRange.start { return toRange.start }
        if self >= fromRange.end { return toRange.end }
        let progression = (self - fromRange.start) / (fromRange.end - fromRange.start)
        return (toRange.end - toRange.start) * progression + toRange.start
    }
    
}