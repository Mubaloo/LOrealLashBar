//
//  GeneralProtocols.swift
//  cisco-phlebotomy_poc-ios
//
//  Created by Jonathan Gwilliams on 05/07/2016.
//  Copyright © 2016 Mubaloo. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 This protocol can be adopted by any object that can be configured using a
 SwiftyJSON `JSON` object. Typically used to populated the local database.
 */
protocol JSONConfigurable {
    func configure(json: JSON) throws
}