//
//  Product+CoreDataProperties.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 02/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var name:        String
    @NSManaged var productID:   String
    @NSManaged var imagePath:   String?

}
