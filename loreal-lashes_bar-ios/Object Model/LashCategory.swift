//
//  LashCategory.swift
//  loreal-lashes_bar-ios
//
//  Created by Igor Nakonetsnoi on 22/09/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class LashCategory: NSManagedObject {

    /** Returns all LashCategory objects in the correct order. */
    class func orderedCategories(context: NSManagedObjectContext = CoreDataStack.shared.managedObjectContext) -> [LashCategory] {
        let fetch = NSFetchRequest(entityName: LashCategory.entityName)
        fetch.sortDescriptors = [NSSortDescriptor(key: "ordinal", ascending: true)]
        do { return (try context.executeFetchRequest(fetch) as? [LashCategory]) ?? [] }
        catch { return [] }
    }
    
    /** Returns all brushes belonging to the receiver, in the correct order. */
    func orderedBrushes() -> [Lash] {
        guard let unorderedSet = lashes else { return [] }
        return unorderedSet.sort({ $0.0.ordinal < $0.1.ordinal })
    }

}

extension LashCategory: JSONConfigurable {
    
    func configure(json: JSON) throws {
        name = try json["category"].string.unwrap("Category Name")
        let brushJSON = try json["lashes"].array.unwrap("Category Lash List")
        lashes = Set(try brushJSON.map({ try Lash.new($0) as Lash }))
        print("\(lashes!.count) brushes in category \(name)")
    }
    
}