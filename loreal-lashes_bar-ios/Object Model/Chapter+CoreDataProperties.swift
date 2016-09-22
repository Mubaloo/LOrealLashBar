//
//  Chapter+CoreDataProperties.swift
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

extension Chapter {

    @NSManaged var name: String
    @NSManaged var timeOffset: Double
    @NSManaged var lash: Lash?
    @NSManaged var technique: Technique?

}
