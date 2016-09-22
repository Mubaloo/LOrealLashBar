//
//  Errors.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 17/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation

enum DataServiceError: ErrorType {
    case NoContentError
}

enum UnwrapError: ErrorType {
    case NoContentError(itemName: String)
}

enum ParseError: ErrorType {
    case InvalidContent(itemName: String)
    case RelationshipTargetNotFound(itemName: String)
}