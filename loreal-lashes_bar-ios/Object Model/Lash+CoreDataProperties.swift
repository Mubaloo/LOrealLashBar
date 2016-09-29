//
//  Lash+CoreDataProperties.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 22/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lash {
    
    @NSManaged var detail:                  String
    @NSManaged var hotTips:                 String
    @NSManaged var inPlaylist:              Bool
    @NSManaged var localMediaPath:          String?
    @NSManaged var localMediaThumbPath:     String?
    @NSManaged var number:                  Int16
    @NSManaged var ordinal:                 Int16
    @NSManaged var remoteMediaPath:         String?
    @NSManaged var thumbPath:               String?
    @NSManaged var length:                  String
    @NSManaged var categories:              Set<LashCategory>?
}