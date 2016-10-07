//
//  Errors.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation

enum DataServiceError: Error {
    case noContentError
}

enum UnwrapError: Error {
    case noContentError(itemName: String)
}

enum ParseError: Error {
    case invalidContent(itemName: String)
    case relationshipTargetNotFound(itemName: String)
}
