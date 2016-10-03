//
//  Technique+CoreDataProperties.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 23/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Technique {

    @NSManaged var name:                    String
    @NSManaged var detail:                  String
    @NSManaged var level:                   String
    @NSManaged var step1:                   String
    @NSManaged var step2:                   String
    @NSManaged var step3:                   String
    @NSManaged var remoteMediaPath:         String?
    @NSManaged var localMediaPath:          String?
    @NSManaged var localMediaThumbPath:     String?
    @NSManaged var thumbPath:               String?
    @NSManaged var ordinal:                 Int16
    @NSManaged var inPlaylist:              Bool

}
