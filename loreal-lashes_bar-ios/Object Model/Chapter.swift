//
//  Chapter.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 24/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Chapter: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Chapter: JSONConfigurable {
    
    func configure(json: JSON) throws {
        name = try json["name"].string.unwrap("Chapter Name")
        timeOffset = try json["time_offset"].double.unwrap("Chapter Time Offset")
        guard let desiredLash = Lash.lashWithName(name) else {
            throw ParseError.RelationshipTargetNotFound(itemName: "Chapter Lash")
        }
        lash = desiredLash
    }
    
}