//
//  LashCategory+CoreDataProperties.swift
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

extension LashCategory {

    @NSManaged var name: String
    @NSManaged var ordinal: Int16
    @NSManaged var detail: String
    @NSManaged var imagePath: String?
    @NSManaged var lashes: Set<Lash>?

}
